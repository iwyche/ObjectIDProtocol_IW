For sounds to be played asynchronously on the Mac, ./soundserver.sh
must be running in the background, and /usr/local/bin/playsound must
exist and be executable.

@softsound is automatically set to restart a background soundserver.sh
on initialization or reinitialization.

To nevertheless ask whether soundserver.sh is running, do, from a Unix prompt:

  % ps auxw | grep soundserver


If you try tunning the server yourself, do it so it runs in background:

  % ./sounderver.sh &



The executable /usr/local/bin/playsound comes from compiling a simple
Mac 10.4 shell application downloaded from
http://steike.com/PlaySound. It is also available on
http://sonnabend.cshl.org/~carlos/tmp/steike_playsound.zip.
             