# zipcode\_fr

Find french city data by zip code and name.

## Usage

```ruby
require 'zipcode-fr'

ZipCode::FR.load                     # builds memory-backed global index

ZipCode.search(:zip, '50000')        # exact zip code search
ZipCode.search(:zip, '50')           # prefixes work
ZipCode.search(:name, 'VERSAILLES')  # search by name
ZipCode.search(:name, 'BORD')        # prefixes work
ZipCode.search(:name, 'MARIE')       # prefixes work on inner words
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
