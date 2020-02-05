# racket-poetry

Poetry to Code interpreter built with Racket

## How it works

```
                 Poem
+----------------------------------------+
| Remember the red sea.                  |
| Pait its empty spaces once with life.  |
| The blue suns have quit.               |
+----------------------------------------+
                   |
                   V
         Dictionary replacements
+----------------------------------------+ red = 2
| MEM (the) 2 1                          | blue, sea, once = 1
| DRAW (its) 0 (spaces) 1 (with) F       | life = F
| (The) 1 (suns) (have) EXIT             | remember = MEM
+----------------------------------------+ paint = DRAW
                   |                       quit = EXIT
                   V
              Chip-8 assembly
+----------------------------------------+
| MEM 021                                |
| DRAW V0,V1 $F                          |
| EXIT 1                                 |
+----------------------------------------+
                   |
                   V
                Binary
+----------------------------------------+
| A021 D01F 0011                         |
+----------------------------------------+
```

## License

```
Copyright (c) 2020 Jérôme Martin <rilouw.eu>
The code for this project is released under the terms of the GNU AGPLv3.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```
