# Sources

Every Ruby rule in this skill has a script in `scripts/` that shows the behavior. The scripts ran clean on Ruby 4.0.3 on 2026-09-20. The Rails rules quote the Rails guides and were not run.

## Ruby

- Ruby core documentation, <https://docs.ruby-lang.org/en/master/>: `NotImplementedError`, `NoMethodError`, `Object#eql?`, `Kernel#system`, `Dir.glob`, `Array#sort`, `Enumerable#sort_by`, `Timeout.timeout`, and the exceptions syntax page.
- The Ruby Style Guide, <https://rubystyle.guide/>: the sections on `and` and `or`, on `raise` over `fail`, and on access modifiers.
- Ruby issue 13804, "Protected methods cannot be overridden", <https://bugs.ruby-lang.org/issues/13804>, open on 2026-09-20.
- RuboCop 1.91.0, Standard 1.56.0, and rubocop-rails-omakase 1.1.0: the rule defaults named in the references were read from the gems' own configuration files and checked by running each linter on a file that holds the fault.

## Design

- Sandi Metz, "Rules for Developers", as reported by thoughtbot, <https://thoughtbot.com/blog/sandi-metz-rules-for-developers>, and "Practical Object-Oriented Design".
- Reek, <https://github.com/troessner/reek>: the smells `UtilityFunction`, `DuplicateMethodCall`, and `IrresponsibleModule`.

## Rails

- Jorge Manrubia, "Vanilla Rails is plenty", <https://dev.37signals.com/vanilla-rails-is-plenty/>, November 8, 2022.
- Rails guides: Active Record callbacks, <https://guides.rubyonrails.org/active_record_callbacks.html>; validations, <https://guides.rubyonrails.org/active_record_validations.html>; querying, <https://guides.rubyonrails.org/active_record_querying.html>.
- `ActiveRecord::Enum`, <https://api.rubyonrails.org/classes/ActiveRecord/Enum.html>.

## Credit

This skill replaces the plain Ruby skills `ruby` and `sandi-metz-rules` from the MIT-licensed superpowers-ruby collection by Lucian Ghinda, <https://github.com/lucianghinda/superpowers-ruby>. It keeps their sound idioms and corrects the advice to use `fail`.
