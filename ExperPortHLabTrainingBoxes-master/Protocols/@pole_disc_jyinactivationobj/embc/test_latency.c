/*
 * TODO:
 *  -Implement FIFO queue of stimulations, with items entering queue upon target threshold crossing.
 *  -Implement logging of all whisker target crossings and saving in MATLAB.
 *  -Verify recording of stim events using 3 column-pair of state matrix.
 *  -Write experiment.
 *
 *
 *
 *
 * NOTES: Evidently cannot use "#define" symbolic constants in EmbC--preprocessor
 *      not used on this code?  Have to make variables instead.
 *
 */

void tick_func(void); 
extern void triggerSchedWave(unsigned wave_id); 
extern double readAI(unsigned chan);
extern int writeAO(unsigned chan, double voltage);
extern unsigned state();
extern void logValue(const char *varname, double val);
extern unsigned logGetSize(void);
TRISTATE thresh_func(int chan, double v);
void init_func(void);

const unsigned stim_dur_473 = 12; /* AOM pulse duration for 473 nm laser. In units of task period. 
                         Hack required to compensate for -75 mV offset of baseline in AO channels going to AOMs.*/
/* unsigned stim_dur_594 = 12 */ /* AOM pulse duration for 594 nm laser. In units of task period. 
                          Hack required to compensate for -75 mV offset of baseline in AO channels going to AOMs.*/

double ao_chan_offset = 0.075;
double whisker_pos_thresh_high = 1.0;
double whisker_pos_thresh_low = 0.5;

struct wave_id_list { /* scheduled wave IDs  REPLACE WITH ENUM*/
    unsigned masking_flash_blue;
    unsigned masking_flash_orange;
    unsigned x_galvo;
    unsigned y_galvo;
    unsigned shutter;
    unsigned aom_473;
    unsigned aom_594;
};
struct wave_id_list wave_ids = {.masking_flash_blue = 2, .masking_flash_orange = 3,
          .x_galvo = 4, .y_galvo = 5, .shutter = 1, .aom_473 = 6, .aom_594 = 7};

unsigned whisker_detector_ai_chan = 4; /* Analog input channel for whisker position readings. */
unsigned aom_473_chan = 4; /* Analog output channel for AOM for 473 nm laser. */
unsigned aom_594_chan = 5; /* Analog output channel for AOM for 594 nm laser. */

unsigned num_ao_chans = 8;

int v_state;
int v_state_last = 0;

unsigned wave_task_period_counter = 0;
unsigned wave_stim_output_flag = 0;

struct varlog_val_list {
    double target_crossing;
    double stim_473nm;
};
struct varlog_val_list varlog_vals = {.target_crossing = 1.0, .stim_473nm = 2.0}; 


void tick_func(void)
{
    unsigned curr_state;
    double v;
    int i;
    
    
    v = readAI(whisker_detector_ai_chan);
    
    if (v >= whisker_pos_thresh_high)
        v_state = 1;
    else if (v <= whisker_pos_thresh_low)
        v_state = 0;
            
    /******** FOR TESTING ************
     * unsigned num_log_items;
     curr_state = state();
    num_log_items = logGetSize();
    if (num_log_items < 100 && curr_state == 41)
        logValue("state_41_log", 3.0);
    ********************/
        
    if (v_state == 1 && v_state_last != 1) { /* Whisker is moving toward center of target */
        logValue("target_crossing", varlog_vals.target_crossing); /* Log that whisker crossed target. */
        
        /* Must be in right state to trigger stim */
        curr_state = state();
        if (curr_state == 41 || curr_state == 42) { /* In state 41, might want to wait ~ 0.5 s for typical pole drop time before enabling stim. */
            triggerSchedWave(wave_ids.aom_473); /* Scheduled wave not best way to do this, because need to have both delay and non-refractoriness. */
            logValue("stim_473nm", varlog_vals.stim_473nm); /* Log that whisker crossed target. */
            wave_stim_output_flag = 1;
        }
    }
    

    
    
    
    if (wave_stim_output_flag == 1) {
        wave_task_period_counter++;
        if (wave_task_period_counter == (stim_dur_473 + 2)) { /* For some reason + 1 task period doesn't work, need + 2.
                                                                                        Then do get 2 sample periods of -0.75 mV, but this isn't too bad.*/
            writeAO(aom_473_chan,ao_chan_offset);
            wave_stim_output_flag = 0;
            wave_task_period_counter = 0;
        }
    }
    
    v_state_last = v_state;
}


void init_func(void)
{ 
    
    unsigned i;
     
        

    
    /* Set all channels to 0 "manually", since Comedi calibration problem
     * leaves a slight voltage offset 
     * Do all channels in for loop instead of this... */
   
    for (i = 1; i <= num_ao_chans; i++)
        writeAO(i,ao_chan_offset);
   

    
}

/* Want to configure second analog input channel (beyond lickport channel)
 * with SetInputEvents.m in order to (1)
 * read in whisker position with readAI(); and (2) to record times of stimulation
 * using scheduled waves event triggering. These events get recorded and made
 * available to MATLAB as input events on this second channel.  We *don't* however
 * want actual input events to get triggered on this channel.  Thus, we re-define
 * the built-in threshold detection function in order to detect events *only* on
 * the lickport channel.
 */
TRISTATE thresh_func(int chan, double v)
{
    if (chan == 0) { /* Lickport input channel = hardware channel 0 */
        if (v >= 4.0) return POSITIVE;  /* if above 4.0 V, above threshold */                                              
        if (v <= 3.0) return NEGATIVE;  /* if below 3.0, below threshold */
        return NEUTRAL; /* otherwise unsure, so no change */
    }
    else { 
        return NEUTRAL; /* Do not allow "beam-break" events on non-lickport channel */
    }
}

