const NFCool = artifacts.require("NFCool");
const expect = require('chai').expect;

contract("NFCool", (accounts) => {
    let [owner, alice, bob] = accounts;
    let contract;

    beforeEach(async () => {
        contract = await NFCool.new({from: owner});
    });
    context("mint a token", async () => {
       let res;
       let tokenName = "AirMax 2000";
       let tokenUri = "testUri";

       beforeEach(async() => {
          res = await contract.mintToken(tokenUri, tokenName, web3.utils.asciiToHex(""), {from: owner});
       });

       it ("Should not throw an error", () => {
           expect(res.receipt.status).to.equal(true);
       });

       it ("Should have expected uri", async () => {
           const uri = (await contract.tokenData(0)).uri;
            expect(uri).to.equal(tokenUri);
       });

        it ("Should have expected name", async () => {
            const name = (await contract.tokenData(0)).name;
            expect(name).to.equal(tokenName);
        });
    });
});
