# zipcode-fr

Find french city data by zip code and name.

[![Build Status](https://travis-ci.org/lloeki/zipcode-fr.svg?branch=master)](https://travis-ci.org/lloeki/zipcode-fr)

## Usage

```ruby
require 'zipcode-fr'

# use it directly
z = ZipCode::FR.new
z.load                         # builds memory-backed global index

z.search(:zip, '50000')        # exact zip code search
z.search(:zip, '50')           # prefixes work
z.search(:name, 'VERSAILLES')  # search by name
z.search(:name, 'BORD')        # prefixes work
z.search(:name, 'MARIE')       # prefixes work on inner words

# use it through ZipCode::DB
ZipCode::DB.for(:fr).load
ZipCode::DB.for(:fr).search(:zip, '50000')
```

Main fields are:

- `:name`: normalised name without diacritics nor symbols
- `:zip`: zip code, as used by postal service

Extra fields are provided:

- `:insee`: INSEE code
- `:alt_name`: alternative name used internally by postal service delivery

## Data source

Data is downloaded from officially vetted source:

- https://www.data.gouv.fr/fr/datasets/base-officielle-des-codes-postaux/

## License

MIT
