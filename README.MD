# Linux Environment Check
A script to help examine a Linux environment before a user starts a remote exam.

## Download the script, set permissions, and run it:
```sh
wget -qO- https://tinyurl.com/hbe34z3w > lecheck.sh
chmod +x lecheck.sh
./lecheck.sh
```

To get an explanation of what the script is looking for, and why, use `-?`:
```sh
./lecheck.sh -?
```

## To launch directly with just one command:

```sh
bash -c "$(wget -qO- https://tinyurl.com/hbe34z3w)"
```

To get an explanation of what the script is looking for, and why, use ` -- -?`:
```sh
bash -c "$(wget -qO- https://tinyurl.com/hbe34z3w)" -- -?
```

## Alternative approach using curl
If wget is not installed, but curl is, you can use these commands:

Download the script, set permissions, and run it:
```sh
curl -fsSL https://tinyurl.com/hbe34z3w > lecheck.sh
chmod +x lecheck.sh
./lecheck.sh
```

To get an explanation of what the script is looking for, and why, use `-?`:
```sh
./lecheck.sh -?
```

To launch directly with just one command:

```sh
bash -c "$(curl -fsSL https://tinyurl.com/hbe34z3w)"
```

To get an explanation of what the script is looking for, and why, use ` -- -?`:
```sh
bash -c "$(curl -fsSL https://tinyurl.com/hbe34z3w)" -- -?
```
