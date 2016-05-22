# Flaming Freedom Backup Tool

Downloads all episodes of Flaming Freedom into the episodes/ directory.

## Usage

````
bundle install
ruby ff.rb
````

The tool is idempotent, meaning it will not re-download an episodes that
already exists in the target directory.

