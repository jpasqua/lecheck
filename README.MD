A script to help examine a Linux environment before a user starts a remote exam.

Download the script, set permissions, and run it:
```sh
curl -s https://raw.githubusercontent.com/jpasqua/lecheck/main/lecheck.sh > lecheck.sh
chmod +x lecheck.sh
./lecheck.sh
```

To get an explanation of what the script is looking for, and why, use `-?`:
```sh
./lecheck.sh -?
```

To launch directly with just one command:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/jpasqua/lecheck/main/lecheck.sh)"
```

There is also a tinyurl for the script:

```sh
bash -c "$(curl -fsSL https://tinyurl.com/hbe34z3w)"

```

To get an explanation of what the script is looking for, and why, use ` -- -?`:
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/jpasqua/lecheck/main/lecheck.sh)" -- -?
```
or
```sh
bash -c "$(curl -fsSL https://tinyurl.com/hbe34z3w)" -- -?
```
