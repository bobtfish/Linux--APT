package Linux::APT::CmdRunner;
use strict;
use warnings;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub run_cmd {
    my ($self, @cmd) = @_;
    my ($out, $fh);
    my $cmd = join(' ', @cmd) . ' 2>&1 |';
    if (open($fh, $cmd)) {
        $out = do { local $/; <$fh> };
        close($fh);
    }
    else {
        die("Could not run $cmd $!");
    }
    return $out;
}

1;

