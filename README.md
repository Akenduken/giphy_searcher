# giphy_searcher

A new Flutter application for searching gifs via Giphy service.


## Installation

Just clone the project and call

``` bash
flutter packages get
```

project uses [http](https://pub.dartlang.org/packages/http) package for Giphy requests

## Time scales

Overall it took little bit more than 5 hours
Major time consuming part was flutter documentation for widgets.

## Weak parts

Full giphy response parsing is not implemented, just part of it.

I used hardcore url constructor for images (due to limitation of time I decided to make in this way)

Not all response variants or errors may be handled

Everything is written in one file. Not enough time for me (and I'm not familiar with flutter project structure) to separate in different files.
At least Model, Views.

Implementation of widgets tree could be better.

Poor testing part, lack of mocking api responses, unit tests, widget test. Just few lines of code

