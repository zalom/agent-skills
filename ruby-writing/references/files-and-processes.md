# Files, processes, and IO

Proof scripts: `scripts/11_io_files_processes.rb`, `scripts/12_child_status_edges.rb`.

## Run a child process without a shell

```ruby
# wrong: one string goes through a shell, and a path that holds ";" runs a second command
system("ls #{path}")

# right: a list of arguments, no shell
system("ls", path)
output, error, status = Open3.capture3("ls", path)
```

Ruby's documentation for `Kernel#system` says "This method has potential security vulnerabilities if called with untrusted input". RuboCop has no rule for this. Brakeman covers the Rails side only.

## Treat the exit status as a value

- `$?` is `nil` before any child has run, and it is local to the thread and the fiber.
- `exitstatus` is `nil` for a child that a signal killed. `status.exitstatus || 1` turns a `SIGTERM` into a plain failure. The shell convention is 128 plus the signal number, so 143 for `SIGTERM`. Read `status.termsig`.
- A child can exit with any code, such as 127 for "command not found". Never pass a child's code through as the program's own exit code when the program defines what its codes mean. Map it on purpose.
- `system(..., exception: true)` raises on a failure: `Errno::ENOENT` for a missing command, `RuntimeError` for a nonzero exit.
- Prefer `Open3`, which returns the status as a value next to the output.

```ruby
def exit_code(status)
  return 128 + status.termsig if status.signaled?

  status.success? ? OK : FAILED
end
```

## Files

- **`Dir.glob` sorts by byte since Ruby 3.0,** so `b10` comes before `b9`. Never let `Dir.glob(pattern).first` or `.last` stand for the lowest, the highest, or the newest. Sort by the number or the time on purpose.
- **`File.write` is not atomic.** A reader can see half a file, and a crash leaves one behind. Write to a temporary file in the same directory, then `File.rename` it over the target. `Lint/NonAtomicFileOperation` covers only the `mkdir unless exist?` shape.
- **Write to `$stdout`, never to `STDOUT`.** Better, take the stream as an argument with `$stdout` as the default, so a test can pass a `StringIO`. `Style/GlobalStdStream` catches the constant form.
