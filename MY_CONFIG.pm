package MY_CONFIG;

use strict;
use warnings;

sub new {
	my $class = shift;
	my $config_file = shift or die "You must argue a config file\n";
	my $self = read_config_file($config_file);
	bless ($self, $class);
	return $self;
}

sub read_config_file {
	my $config_file = shift;
	my %output;
	open CONFIG, $config_file or die "Couldn't open $config_file\n";
	while (<CONFIG>) {
		my @pair = split(/=/, $_);
		chomp @pair;
		$output{$pair[0]} = $pair[1];
	}
	return \%output;
}

1;
