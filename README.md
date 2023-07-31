# Call Simulation

It's fairly common to try to predict what a transaction might return, or how it would affect other contracts. There are
many ways to do so, ranging from complex solutions like Tenderly or Alchemy, to simple static calls. One popular way is
through the use of Multicall, which allows to group many different calls into one, therefore avoiding being rate limited
by RPCs.

However, there is one area where Multicall might not be the best solution. For example, if you tried to simulate
multiple swap transactions to figure out which one would yield better results, a Multicall won't work. Since the first
call would modify the storage and transfer tokens between accounts, it could happen than all other quotes would fail.
However, it would be interesting to be able to simulate these quotes without actually affecting the state.

And that's where this repository comes into place. The idea is to give existing contracts the ability to simulate calls
in a stateless way, so that they can be run independently from each other. Also, it provides the ability to simulate
these calls similarly to a Multicall, so as to avoid issues with RPC rate limiting.

## Usage

This is a list of the most frequently needed commands.

### Build

Build the contracts:

```sh
$ forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Compile

Compile the contracts:

```sh
$ forge build
```

### Coverage

Get a test coverage report:

```sh
$ forge coverage
```

### Format

Format the contracts:

```sh
$ forge fmt
```

### Gas Usage

Get a gas report:

```sh
$ forge test --gas-report
```

### Lint

Lint the contracts:

```sh
$ pnpm lint
```

### Test

Run the tests:

```sh
$ forge test
```

## License

This project is licensed under GLP 3.0.
