package ColorThief;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');
#use version; $VERSION = qv('0.0.3');

# Other recommended modules (uncomment to use):
#  use IO::Prompt;
#  use Perl6::Export;
#  use Perl6::Slurp;
#  use Perl6::Say;

use Image::Magick;
use Data::Dumper;
local $Data::Dumper::Indent = 1;
local $Data::Dumper::Terse = 1;
use List::Util qw(max min);
use Carp;

sub get_color_name_by_img {
	my $self = shift;
	my ($img) = @_;
	croak "no image file." unless $img;

	my $hsvs_ref = $self->_get_hsv_by_img($img);
	my $hsvs_with_colors_ref = $self->_get_colors_by_hsv($hsvs_ref);
	my $color_palette_href = $self->_count_colors_in_palette($hsvs_with_colors_ref);
	my $color_name = $self->_get_color_name_by_palette($color_palette_href);
	return $color_name ? $color_name : "NO-COLOR";
}

sub new {
	my $class = shift;
	bless {
	}, $class;
}

sub _get_hsv_by_img {
	my $self = shift;
	my ($img) = @_;
	$img or return;

	my $im = Image::Magick->new;
	open(IMAGE, $img);
	$im->Read(file => \*IMAGE);
	close(IMAGE);

	my ($w, $h) = $im->Get('width', 'height');

	my @pixels = $im->GetPixels(
		width => $w,
		height => $h,
		x => 0,
		y => 0,
		map => 'RGB',
	);

	my @rgbs;
	my @hsvs;
	while (@pixels) {
		my %rgb_hash;
		$rgb_hash{r} = (int((shift @pixels) / 256) / 255);
		$rgb_hash{g} = (int((shift @pixels) / 256) / 255);
		$rgb_hash{b} = (int((shift @pixels) / 256) / 255);
		push @rgbs, \%rgb_hash;

		my $max = max $rgb_hash{r}, $rgb_hash{g}, $rgb_hash{b};
		my $min = min $rgb_hash{r}, $rgb_hash{g}, $rgb_hash{b};

		my %hsv_hash;
		$hsv_hash{v} = $max;
		$hsv_hash{s} = 255 * ( ($max - $min) / $max );

		if ($hsv_hash{s} == 0) {
			#s=0のとき、white-blackの色調で、背景色の可能性が高い
			next;
		}
		elsif ($max == $rgb_hash{r}) {
			$hsv_hash{h} = 60 * ( ($rgb_hash{g} - $rgb_hash{b}) / ($max - $min) );
		}
		elsif ($max == $rgb_hash{g}) {
			$hsv_hash{h} = 60 * ( 2 + ($rgb_hash{b} - $rgb_hash{r}) / ($max - $min) );
		}
		elsif ($max == $rgb_hash{b}) {
			$hsv_hash{h} = 60 * ( 4 + ($rgb_hash{r} - $rgb_hash{g}) / ($max - $min) );
		}
		else {
			next;
		}
		push @hsvs, \%hsv_hash;
	}
	return \@hsvs;
}

sub _get_colors_by_hsv {
	my $self = shift;
	my ($hsvs) = @_;
	return unless (ref($hsvs) eq 'ARRAY');

	my @hsv_with_color;
	for my $hsv (@$hsvs) {
		if (!$hsv->{h}) {
			next;
		}
		elsif (($hsv->{h} >= 0 && $hsv->{h} < 20) || ($hsv->{h} >= 330 && $hsv->{h} < 360)) {
			$hsv->{color} = 'RED';
		}
		elsif ($hsv->{h} >= 20 && $hsv->{h} < 50) {
			$hsv->{color} = 'ORANGE';
		}
		elsif ($hsv->{h} >= 50 && $hsv->{h} < 70) {
			$hsv->{color} = 'YELLOW';
		}
		elsif ($hsv->{h} >= 70 && $hsv->{h} < 85) {
			$hsv->{color} = 'LIME';
		}
		elsif ($hsv->{h} >= 85 && $hsv->{h} < 171) {
			$hsv->{color} = 'GREEN';
		}
		elsif ($hsv->{h} >= 171 && $hsv->{h} < 192) {
			$hsv->{color} = 'AQUA';
		}
		elsif ($hsv->{h} >= 192 && $hsv->{h} < 265) {
			$hsv->{color} = 'BLUE';
		}
		elsif ($hsv->{h} >= 265 && $hsv->{h} < 290) {
			$hsv->{color} = 'VIOLET';
		}
		elsif ($hsv->{h} >= 290 && $hsv->{h} < 330) {
			$hsv->{color} = 'PURPLE';
		}
		else {
			next;
		}
		push @hsv_with_color, $hsv;
	}
	return \@hsv_with_color;
}

sub _count_colors_in_palette {
	my $self = shift;
	my ($hsv_with_color) = @_;

	my %color_palette = (
		RED		=> 0,
		ORANGE	=> 0,
		YELLOW	=> 0,
		LIME	=> 0,
		GREEN	=> 0,
		AQUA	=> 0,
		BLUE	=> 0,
		VIOLET	=> 0,
		PURPLE	=> 0,
	);

	my @colors = map { $_->{color} } @$hsv_with_color;
	for my $color (@colors) {
		for my $palette_key (keys %color_palette) {
			if ($color eq $palette_key) {
				$color_palette{$palette_key}++;
			}
		}
	}
	return \%color_palette;
}

sub _get_color_name_by_palette {
	my $self = shift;
	my ($color_palette_href) = @_;

	my @sorted_colors = map { $_->[0] } sort { $b->[1] <=> $a->[1] } map { [$_, $color_palette_href->{$_}] } keys %$color_palette_href;
	return shift @sorted_colors;
}



1; # Magic true value required at end of module
__END__

=head1 NAME

ColorThief - [One line description of module's purpose here]


=head1 VERSION

This document describes ColorThief version 0.0.1


=head1 SYNOPSIS

    use ColorThief;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
ColorThief requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-colorthief@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

libitte  C<< <n@example.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, libitte C<< <n@example.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
