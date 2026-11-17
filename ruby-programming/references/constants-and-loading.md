# Constants and loading

Proof script: `scripts/13_constants_and_load.rb`.

- **Require what the file names.** In a gem or a script tree, add a `require_relative` for every sibling whose constant the file uses. A constant that arrives through another file's `require` disappears when that file changes. No linter catches this. The Ruby LSP can: jump to the definition and check that the file that defines it is required.
- **`require_relative` resolves against the file. `require` resolves against `$LOAD_PATH`.** Both load a file once by its real path, so a symlinked copy loads twice.
- **`require` returns `false` the second time.** That is not an error. Never branch on the return value.
- **The compact form `class A::B` does not open the scope of `A`.** A constant defined in `A` is not found inside `class A::B`. Write the nested form, `module A` and then `class B`, or qualify each constant in full. `Style/ClassAndModuleChildren` asks for the nested form in RuboCop as a style point. Standard turns it off.
- **Constant lookup goes through the lexical scope first,** then through the ancestors of the innermost scope. A constant that exists only in the caller's scope is not found.
- **Assigning a constant again only warns.** Nothing stops the change. Treat the warning as a fault.
