void tick_func(void); 
extern void triggerSchedWave(unsigned wave_id); 
extern double readAI(unsigned chan);
extern unsigned state();
TRISTATE thresh_func(int chan, double v);

void tick_func(void)
{
    unsigned wave_id = 1; /* scheduled wave ID */
    unsigned chan = 4; /* Analog input channel for whisker position readings.
                        */
    unsigned curr_state; 
    double v;

    static int v_state = 0;
    static int v_state_last = 0;
    
    v = readAI(chan);
    
    if (v >= 4.0) 
       v_state = 1;
    else if (v <= 3.0)
       v_state = 0;
        
    if (v_state != v_state_last) { /* There was a change of state */
        curr_state = state();
        if (curr_state == 41 || curr_state == 42) /* Must be in right state to trigger wave */
            triggerSchedWave(wave_id);
    }
    
    v_state_last = v_state;

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

