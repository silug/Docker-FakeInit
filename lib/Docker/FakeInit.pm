package Docker::FakeInit;

use strict;
use warnings;

use Carp;
use IO::Handle;

use POSIX qw(setpgid tcsetpgrp pause :sys_wait_h :errno_h);

our $VERSION=0.01;

INIT {
    our $break=0;

    our $pid=fork();

    if ($pid == -1) {
        # fork() failed
        carp "fork() failed: $!. Not setting up SIGCHLD handler.";
    } elsif ($pid == 0) {
        # In the child.
    } else {
        # In the parent
        my @signals=qw(HUP INT QUIT USR1 USR2 PIPE TERM TSTP TTIN TTOU WINCH);
        for my $signal (@signals) {
            $SIG{$signal}=sub { ($break)=@_ };
        }
        $SIG{'CHLD'}=sub { $break=0 };
        $SIG{'ALRM'}=sub { $break=0 };

        while (kill(0, $pid)) {
            # Child is still alive
            alarm(10); # Wake up every 10 seconds to check for zombies
            pause; # Wait for a signal
            kill($break, $pid) if ($break); # Pass HUP/INT/QUIT/TERM on to child

            # Reap any dead children
            my $kid;
            do { $kid=waitpid(-1, WNOHANG); } while ($kid > 0);
        }
        exit 0;
    }
}

1;
