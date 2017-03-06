# @thrash/compare

Compare performance of multiple thrashers on same inputs.


## Install

```sh
npm install @thrash/compare --save-dev
```


## Usage

See [@thrash/fn](https://github.com/elidoran/thrash-fn) to learn how the basics work.

```javascript
var thrash = require('@thrash/fn')
  , compare = require('@thrash/compare')
  , thrash1 = thrash 'some-module1', { label:'original' }
  , thrash2 = thrash 'some-module2', { label:'rewrite' }
  , thrashBoth = compare('major change', thrash1, thrash2, {
    // some optional options
  })

// apply the console plugin and we'll see the comparison
thrashBoth.use('@thrash/console', {
  width: 15,     // column width (padded)
  separator: '|' // column separator
})

// then thrash it a million times with some inputs
thrashIt({ repeat:1e6, with:[ inputs ]})
```

The output will be something similar to the below. (Your results will one one input block per input you provide the thrasher).

It will now have a new line showing the difference in time take for later thrashers compared to the first (baseline) one. It helps draw attention to that line with `'(change factor)'` label and putting `'(baseline)'` under the first thrasher's results for each input.

It uses `chalk` to color good things green and bad things red.

```sh
     inputs     |    original    |    rewrite     
-------------------------------------------------
123456789012    |          valid |          valid
                |    optimizable |    optimizable
                |           0 s  |           0 s  
                |   2,030,672 ns |     990,117 ns
(change factor) |     (baseline) |          2.05x
-------------------------------------------------
```


## TODO:

1. min
2. max
3. mean
4. median
5. analyze and describe variances based on different inputs used. For example, when the input is a string, what happens as the string gets longer? Or, when a number is smaller? or an integer versus a float?


### MIT License
