function use_outside_path(path)
  table.insert(  emulate_mode_rules, 1,
    {dir = path, rules = { {dir = path, use_orig_path = true}, }, })
end

-- Allow user-defined rules to "overlay" what we've defined here.
-- What is in ~/.sbrules gets executed as if its contents were in this file, on this line.
function run_sbrules()
  do
    local home = os.getenv('HOME')

    -- os.getenv() can return nil if (for some reason) $HOME isn't defined
    -- concatenating nil with '/.sbrules' would crash the script and issue a backtrace
    if home then
        -- We could call .sbrules via pcall to trap errors but that just hides them from the user
        -- pcall(dofile, home .. '/.sbrules')
        dofile(home .. '/.sbrules')
    end
  end
end
