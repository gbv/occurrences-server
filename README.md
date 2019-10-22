# Occurrences Server

> JSKOS Server for Occurrences data

This is a prototype coded in Perl to analyze how classification data is used in K10plus library catalogue.

## Installation

Clone from GitHub:

    git clone https://github.com/gbv/occurrences-server.git
    cd occurrences-server

Install requires Perl modules:

    cpanm --installdeps .

Start the application:

    plackup -R lib

The database with be empty by default.

## Development

Run on port 5000 with reload on changes:

    plackup -R lib

