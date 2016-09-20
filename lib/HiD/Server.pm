# ABSTRACT: Helper for 'hid server'

=head1 DESCRIPTION

Helper for C<hid server>

=cut

package HiD::Server;

use 5.014; # strict, unicode_strings
use warnings;

use parent 'Plack::App::File';

=method locate_file

Overrides L<Plack::App::File>'s method of the same name to handle '/' and
'/index.html' cases

=cut

sub locate_file {
  my ($self, $env) = @_;

  my $path = $env->{PATH_INFO} || '';

  $path =~ s|^/|| unless $path eq '/';

  if ( -e -d $path and $path !~ m|/$| ) {
    $path .= '/';
    $env->{PATH_INFO} .= '/';
  }

  $env->{PATH_INFO} .= 'index.html'
    if ( $path && $path =~ m|/$| );

  return $self->SUPER::locate_file( $env );
}

=method return_400 return_403 return_404

Overrides L<Plack::App::File>'s 400,403,404 handlers
to return either configured or default html pages
instead of the default messages

=cut

sub _return_400 {
  return $_[0]->_error_code_handler(400)
}

sub _return_403 {
  return $_[0]->_error_code_handler(403)
}

sub return_404 {
  return $_[0]->_error_code_handler(404)
}

=method serve_path

Overrides L<Plack::App::File>'s serve_path method
to put in alternate http response codes

=cut

sub serve_path {
  my ($self, $env, $file) = @_;

  my $response = $self->SUPER::serve_path( $env, $file );

  my $alternate_status = delete $self->{use_http_status_of};

  $response->[0] = $alternate_status
    if ( $response->[0] == 200 && $alternate_status );

  return $response;
}

sub _error_code_handler {
  my ($self, $code) = @_;

  #default page name e.g. 404.html
  my $default_page = "$code.html";

  my $super = "SUPER::return_$code";
  return $self->$super()
    if ( grep /^searching/, keys %$self );

  #stack of possible error pages to search
  my @search = ( $default_page );

  #if a custom page added via the config push it onto the stack
  my $custom_page = $self->{error_pages}->{$code};

  push @search, $custom_page
    if ( $custom_page && lc($custom_page) ne lc($default_page) );

  while ( my $page = pop( @search ) ) {
    #set the flag so we know what we're searching for
    $self->{'searching_'.$page} = 1;
    my ($file, $path_info) =
      $self->locate_file( { PATH_INFO => '/'.$page });

    #done searching now in any case
    delete $self->{'searching_'.$page};

    #the Array ref indicates file not found let's check the next file
    next if ( ref $file eq 'ARRAY' );

    #set the http error response code for use in the actual response
    $self->{use_http_status_of} = $code;
    return ( $file, $path_info );
  }
  #found no custom or default error page lets return the default Plack error message;
  return $self->$super();
}

1;
