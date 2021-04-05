## Note

Note that we're using 3.x version of Open Zeppelin contract on Hardhat

And using 4.x version of Open Zeppelin on remix

Both are pretty much the same except one function call.

Docs (3.x) : https://docs.openzeppelin.com/contracts/3.x/api/token/erc20

## Hardhat setup

Please add your account private key in hardhat.config.js

## Contructor

The contructor takes in 3 arguments -- (address, string, uint)

1. address - address of owner of repo to send them 100 tokens
2. string - link to repo
3. uint - cap of the total supply of tokens

For 3., please add 18 zeros after the number of tokens to mint. Will fix this issue soon.

So 100 tokens would be 10000000000000000000

For hardhat, these are hardcoded in the deploy.js script
# minerva-contract
# minerva-contract
