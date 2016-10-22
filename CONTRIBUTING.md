# Contribution guidelines

## Tests and documentation

All pull requests must have tests associated with them in the appropriate ```/t``` dir and ensure ```prove -lv t/``` passes.

Please include ```POD``` for new methods and update the wiki for new routes

## perlbrew

All development must be done using ```perlbrew``` with ```5.22``` and use the ```#!/usr/bin/env perl``` shebang where appropriate

## Perl styling

0) Spaces. No tabs. Four spaces indents:

```perl
sub do_something {
    my $self = shift;
}
```

1) Do not break lines for curly braces.

do:

```perl
foreach my $value (@values) {
```

not

```perl
foreach my $value (@values)
{
```

2) Use ```$self``` to hold the current ```PACAKGE```.

do:

```perl
sub some_method {
    my $self = shift
}
```

not:

```perl
sub some_method {
    my $obj = shift
}
```

3) use ```Moose``` - do not create your own constructors

4) Do not write raw ```SQL``` in the Perl code. Utilize the database scaffold and the methods from [DBIx::Class::ResultSet](http://search.cpan.org/dist/DBIx-Class/lib/DBIx/Class/ResultSet.pm)

5) Object style method calls are much preferred.

do:

```perl
$self->method;
```

not:

```perl
method();
```

never:

```perl
&method;
```

6) Try your best to match the styling of the original code base

7) Remove all debug statements from pull requests. Never use ```print``` in the API layer

8) Use ```Moose``` attributes to construct ```PACKAGE```s instead of ```Package::Name->new```

9) Never directly use a ```Controller``` or ```Core``` module in the ```Route```s. Create a plugin with the following namespaces:

```perl
package API::Plugins::RouteNameManager;

use Dancer ':syntax';
use Dancer::Plugin;

use API::Controller::RouteName;

register route_name_manager => sub { 
    API::Controller::RouteName->new;
};
register_plugin;

true;
```

10) Use ```try/catch``` blocks for exception handling:

do:

```perl
try {
    $self->do_something;
} catch {
    die "Something went wrong: $_";
};
```

not:

```perl
eval { $self->do_something };

if (@$) {
    die "Something went wrong: $_";
}
```

## Adding modules

If you must add a new module, please list it in the ```cpanfile```
