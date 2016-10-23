## Peptide Retention API

Hello! This doc contains instructions for setting up the API.

For information about what the API does and how to use it, please refer to the [wiki](https://github.com/connoryates/peptide_retention/wiki/Overview)

### Requirements:

- perlbrew with Perl v5.22

- Debian-based Linux

- Postgres 9.6

- Redis

### Setup

You will need a Postgres instance along with a seed data file (which is not available through this repo) to begin.

Build the app dependencies with:

```bash
$ ./bin/build-app
```

*Make sure you do not run this as root!* But as a user with ```sudo``` access. This will install ```perlbrew```
and call the command: ```cpanm -nlv --installdeps .``` which reads all of the Perl dependencies listed in the ```cpanfile``` and builds them.

Add this line to your ```~/.bash_profile```:

```bash
source ~/perl5/perlbrew/etc/bashrc
```

Open your Postgres instance and run the commands in ```db/schema.sql```.

Ensure all of the tests pass:

```
$ prove -lv xt/
$ prove -lv t/
```

### Seeding the database

(NOT MADE YET)

Place your seed data file in ```peptide_retention/data/seed/$your_file```

Run the script:

```
$ perl dev-bin/seed.pl --file '$file_name'
```

### Web Server

The web server runs on [Dancer](http://perldancer.org/) and [Starman](http://search.cpan.org/~miyagawa/Starman-0.1000/lib/Starman.pm) and uses REST end points

The web server doesn't run in the background and produces output so be sure you have multiple shells or [```tmux``` ```screen```] sessions running

Fire the web server:

```
PLACK_ENV=development starman bin/app.pl
```

You must specify the ```PLACK_ENV```, right now only ```development``` is supported

This should bind the server to: ```http://0.0.0.0:5000```

In another shell, hit the healthcheck enpoint:

```
curl -X GET http://0.0.0.0:5000/healthcheck
```

Please report any issues you have with the setup.

If everything goes smoothly, see the wiki for more information
