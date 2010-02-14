package Linux::APT::CmdRunner::Remote;
use strict;
use warnings;
use IPC::ShellCmd;
use IPC::ShellCmd::SSH;
use IPC::ShellCmd::Sudo;

sub new {
    my $class = shift;
    my $p = shift;
    bless {map { $_ => $p->{$_} } qw/ host user sudo /}, $class;
}

sub run_cmd {
    my ($self, @cmd) = @_;
    use Data::Dumper;
    warn Dumper(\@cmd);
    my $isc = IPC::ShellCmd->new([@cmd])
            ->stdin(-filename => "/dev/null");

    if ($self->{sudo}) {
        $isc = $isc->chain_prog(
            IPC::ShellCmd::Sudo->new(
                User => 'root',
                SetHome => 0,
             )
         );
    }
    $isc = $isc->chain_prog(
                IPC::ShellCmd::SSH->new(
                    User => $self->{user},
                    Host => $self->{host},
                )
            );
    $isc->run;
    my $stdout = $isc->stdout();
    my $status = $isc->status();
    if ($status) {
        my $cmd = join(' ', @cmd);
        warn("Could not run $cmd $!\n");
        warn $isc->stderr;
        exit 1;
    }
    return $stdout;
}

1;

