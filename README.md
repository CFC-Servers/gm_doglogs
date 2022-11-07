# gm_doglogs

A collection of modules that add more informative log messages for use in log processing apps like DataDog

[![GLuaTest](https://github.com/CFC-Servers/gm_doglogs/actions/workflows/gluatest.yml/badge.svg)](https://github.com/CFC-Servers/GLuaTest)


## Adding a module
Create a new file in `lua/doglogs/modules/`, create your hook/wrap, and log your message with the `DogLogs.Log` function.

Then, create a new test file with the same name in `lua/tests/doglogs/modules/`. Some general ideas of what to test for:
 - That the module loaded (the hook exists, the function is wrapped, etc.)
 - That the module produces the correct log line in best-case scenarios
 - That the module produces the correct log line in weird, or atypical scenarios

## Advice for logging

### Surround important fields with delimiters
When making a parsing pattern, it's much easier to pull out the fields you want if they're surrounded with quotes, brackets, parens, etc.

In general, using double quotes around a player name, and `<>` around a steam ID are solid.


### Making a new extractor
For CFC's DataDog instance, you'll want to hover over "**Logs**" on the left panel, then go to "**configuration**".

Then, under the "**gmod**" pipeline, there are three parsers:
 - The [gm_logger](https://github.com/CFC-Servers/gm_logger) parsing rule (you don't have to touch this)
 - The **GMod Events** parser (this is for logs that gmod itself produces)
 - The Addon Events parser (this is for logs that addons produce)

For any new logs added in this addon, it's probably best to put them in the **Addon Events** parser.

Click the Edit button on the Parser.

Now you'll see the Parser edit page. It has 3 sections:
 - Name the processor
 - Log samples
 - Define parsing rules

So your goal here is to get an example log that your module produces, and put it in one of the boxes under "Log samples".
It should have a red `NO MATCH` box next to it.

Now, we need to make the grok parsing rule. It's probably best if you copy from existing rules (check out the rules in the GMod Events parser for lots of working patterns).

#### Some general tips to help you make patterns
 - Always escape `(`, `)`, `[`, `]` with a backslash `\`
 - Rules begin with a rule name, like: `initial_spawn the-actual-pattern-starts-here`
 - Extractions are defined in the format of `%{type:name}`, where `type` is the parsing type (see a list of available types [here](https://docs.datadoghq.com/logs/log_configuration/parsing/?tab=matchers#matcher-and-filter)), and `name` is the name of the extracted field in the logs
 - The `name` in your extractions can be objects, too, so for example: `%{data:player.name}` would extract that section into the `name` field of a new `player` object (so in the log viewer you'd see: `{ player: { name: blah } }`)
 - Player names should be parsed with: `%{data:player.name}`
 - Player steam ID's should be parsed with: `%{data:player.steam_id}`
 - IPs should be parsed with: `%{ip:player.ip}` or `%{ip:remote.ip}` if it's not a player's IP (remember that IPs are hashed _after_ these rules, so you still have to treat it as an IP at this point)
 - You can match a section of text without actually extracting it. For example, if there was a variable number that you didn't care about, you could match it with: `%{data}` and simply not include the `name` portion
 - The Log Samples section is limited to only 5 samples, so you'll eventually have to delete old samples. It's a good idea to copy the samples and re-paste them when you're done to make sure they still work
 - There is a section that pops up below the "Define parsing rules" box - this section shows an example of what your rule will extract from the sample (**Note**: this only shows an example of the Sample you most recently clicked into)
