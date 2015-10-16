% MY TITLE
% Author Raphael Cohn
% June 15, 2006

<http://www.luafaq.org/#T1.11>

Inline image is ![Banias Spring and Pan's Cave](banias-spring.jpg "Banias Spring and Pan's Cave from Wikipedia") .

![Banias Spring and Pan's Cave]

[Banias Spring and Pan's Cave]: banias-spring.jpg

![Banias Spring and Pan's Cave](banias-spring.jpg)

![Banias Spring and Pan's Cave](banias-spring.jpg "Banias Spring and Pan's Cave from Wikipedia")

```
	Code Block
	Hello
```

* fruits
    + apples
        - macintosh
        - red delicious
    + pears
    + peaches
* vegetables
    + broccoli
    + chard

+ A lazy, lazy, list
item.

+ Another one; this looks
bad but is legal.

    Second paragraph of second
list item.

1.  one
2.  two
3.  three

Term 1

:   Definition 1

Term 2 with *inline markup*

:   Definition 2

        { some code, part of Definition 2 }

    Third paragraph of definition 2.


Term 1
  ~ Definition 1

Term 2
  ~ Definition 2a
  ~ Definition 2b



|Table Header 1|Table Header 2:|
|--------------|--------------:|
|Value 1|Value 2|
|Value 3|Value 4|


This is a paragraph

* one
* two
* three

* here is my first
list item.
* and my second.

* First paragraph.

    Continued.

  * Second paragraph. With a code block, which must be indented
    eight spaces:

        { code }




#. one
#. two

 9)  Ninth
10)  Tenth
11)  Eleventh
       i. subone
      ii. subtwo
     iii. subthree

(@)  My first example will be numbered (1).
(@)  My second example will be numbered (2).

Explanation of examples.

(@)  My third example will be numbered (3).

(@good)  This is a good example.

As (@good) illustrates, ...


  Right     Left     Center     Default
-------     ------ ----------   -------
     12     12        12            12
    123     123       123          123
      1     1          1             1

Table:  Demonstration of simple table syntax.


-------------------------------------------------------------
 Centered   Default           Right Left
  Header    Aligned         Aligned Aligned
----------- ------- --------------- -------------------------
   First    row                12.0 Example of a row that
                                    spans multiple lines.

  Second    row                 5.0 Here's another one. Note
                                    the blank line between
                                    rows.
-------------------------------------------------------------

Table: Here's the caption. It, too, may span
multiple lines.




# Header1


: Sample grid table.

+---------------+---------------+--------------------+
| Fruit         | Price         | Advantages         |
+===============+===============+====================+
| Bananas       | $1.34         | - built-in wrapper |
|               |               | - bright color     |
+---------------+---------------+--------------------+
| Oranges       | $2.10         | - cures scurvy     |
|               |               | - tasty            |
+---------------+---------------+--------------------+


| Right | Left | Default | Center |
|------:|:-----|---------|:------:|
|   12  |  12  |    12   |    12  |
|  123  |  123 |   123   |   123  |
|    1  |    1 |     1   |     1  |

  : Demonstration of pipe table syntax.



## Header2

This ~~struck out~~. H~2~O is a liquid.  2^10^ is 1024. `<$>`{.haskell}

This is *italic*.

This is **bold**.

This is ***bold italic***.

What is the difference between `>>=` and `>>`?

<defn>This is raw HTML.</defn>

<http://google.com>
<sam@green.eggs.ham>

This is an [inline link](/url), and here's [one with
a title](http://fsf.org "click here for a good time!").

[Write me!](mailto:sam@green.eggs.ham) after reading [my label 3].


[my label 3]: http://fsf.org (The free software foundation)

### Header3

Here is a footnote reference,[^1] and another.[^longnote]

[^1]: Here is the footnote.

[^longnote]: Here's one with multiple blocks.

    Subsequent paragraphs are indented to show that they
belong to the previous footnote.

        { some.code }

    The whole paragraph can be indented, or just the first
    line.  In this way, multi-paragraph footnotes work like
    multi-paragraph list items.

This paragraph won't be part of the note, because it
isn't indented.




