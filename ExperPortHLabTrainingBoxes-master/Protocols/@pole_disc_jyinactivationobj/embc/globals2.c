void tick_func(void); 
extern void triggerSchedWave(unsigned wave_id); 
extern double readAI(unsigned chan);
extern unsigned state();
TRISTATE thresh_func(int chan, double v);
int v_state;
int v_state_last;
unsigned last_state;

void tick_func(void)
{
    unsigned wave_id_masking_flash_blue = 2; /* scheduled wave ID */
    unsigned wave_id_masking_flash_orange = 3; /* scheduled wave ID */
    unsigned wave_id_x_galvo = 4; /* scheduled wave ID */
    unsigned wave_id_y_galvo = 5; /* scheduled wave ID */
    unsigned wave_id_shutter = 1; /* scheduled wave ID */
    unsigned wave_id_aom_473 = 6; /* scheduled wave ID */
    unsigned wave_id_aom_594 = 7; /* scheduled wave ID */
    
    unsigned chan = 4; /* Analog input channel for whisker position readings.
                        */
    unsigned curr_state; 
    double v;

    extern int v_state;
    extern int v_state_last;
    
    extern unsigned last_state;
    
    v = readAI(chan);
    
    if (v >= 2.0) 
       v_state = 1;
    else if (v <= 0.5)
       v_state = 0;
        
    if (v_state == 1 && v_state_last != 1) { /* Whisker is moving toward center of target */
        curr_state = state();
        /* Must be in right state to trigger wave */
        /* if (curr_state == 41 || curr_state == 42) */
        if (curr_state == 41 || curr_state == 42 || curr_state == 43) { 
            triggerSchedWave(wave_id_aom_473); 
        }
    }
    
    v_state_last = v_state;

    /********************************/
    curr_state = state();
    if (curr_state == 41 && curr_state != last_state) {
        triggerSchedWave(wave_id_masking_flash_blue);
        triggerSchedWave(wave_id_masking_flash_orange);
        triggerSchedWave(wave_id_shutter);
        triggerSchedWave(wave_id_x_galvo); 
        triggerSchedWave(wave_id_y_galvo);
       /* triggerSchedWave(wave_id_aom_473);
        triggerSchedWave(wave_id_aom_594); */
    }
    
    last_state = curr_state;
    /********************************/
    
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

