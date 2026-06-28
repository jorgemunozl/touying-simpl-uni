<p align="center">
    <img width="50%" src="./thumbnail.png"/>
</p>

# Touying Slide Theme for National University of Engineering

[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)

A slide theme for the National University of Engineering (UNI) based on the [Touying](https://github.com/touying-typ/touying) presentation framework.

Adapted from the [Touying slide theme for ECNU](https://github.com/ccyoung3/touying-simpl-ecnu), which was modified from [CAU](https://github.com/maxchang3/touying-simpl-cau/) and [originally created for Beihang University](https://github.com/Coekjan/touying-buaa).

## Usage

### Import the theme in existing projects

```typst
#import "@preview/touying:0.6.1": *
#import "@preview/touying-simpl-ecnu:0.0.1": *

#show: ecnu-theme.with(
    config-info(
        title: [Touying for ECNU: Customize Your Slide Title Here],
        subtitle: [Customize Your Slide Subtitle Here],
        author: [Authors],
        date: datetime.today(),
        institution: [National University of Engineering],
    ),
    // use-background: false, // Uncomment to disable background image
)

#title-slide() // Create a title slide

#outline-slide() // Create an outline slide

// Add your content here
```

### Create a new project with `typst init`

Quickly scaffold a new presentation with:

```console
$ typst init @preview/touying-simpl-ecnu
Successfully created new project from @preview/touying-simpl-ecnu:<latest>
To start writing, run:
> cd touying-simpl-ecnu
> typst watch main.typ
```

## Examples

![Title slide](thumbnail.png)

See [examples](examples) for more details.

Compile the examples yourself:

```console
$ typst compile ./examples/main.typ --root .
```

The compiled presentation will be available at `./examples/main.pdf`.

## Development

This package is maintained using:

- [Typship](https://github.com/sjfhsjfh/typship) - for publishing to the Typst package registry.
- [Typst Upgrade](https://github.com/Coekjan/typst-upgrade) - for upgrading Typst packages.

## License

Licensed under the [MIT License](LICENSE).
