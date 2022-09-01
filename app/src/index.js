
import Web3 from "web3";

import bitBarterArtifact from "../../build/contracts/BitBarter.json";

//const Web3 = require('web3')
const App = {
  web3: null,
  account: null,
  meta: null,
  barter:null,
  imposter: null,
  customer: null,
  provider: null,
  customerBalance: null,

  start: async function () {
    const { web3 } = this;

     try {
      // get contract instance
      const networkId = await web3.eth.net.getId();

      const deployedNetwork = bitBarterArtifact.networks[networkId];
      console.log(bitBarterArtifact);
      console.log(deployedNetwork);

      let accounts = await this.web3.eth.getAccounts();
      this.customer = accounts[0];
      this.provider = accounts[1];
      this.imposter = accounts[2];

      //initialize a new contract handler.
      this.barter = await new web3.eth.Contract(
        bitBarterArtifact.abi,
        deployedNetwork.address,
      );

      console.log(this.barter);

    } catch (error) {
      console.error("some error happened");
    }
  },

  createJob: async function () {
    const title = document.getElementById("title").value;
    const description = document.getElementById("description").value;

    const price = document.getElementById("price").value
    let priceInWei = await this.web3.utils.toWei(price, 'ether')
    console.log(this.barter);

    var callJob= await this.barter.methods.openJobForProvider(title, description, this.provider).send({
    from: this.customer,
    value: priceInWei,
    gas: 299999,
    gasPrice: '300000'
    });
     document.getElementById("title").innerHTML = ``
     document.getElementById("description").innerHTML = ``
     document.getElementById("price").innerHTML = ``

  },


  getBalance: async function(){
    let balance = await this.web3.eth.getBalance(this.customer)
    this.customerBalance = await this.web3.utils.fromWei(balance,'ether')
    console.log(this.customerBalance)
    document.getElementById("balance").innerHTML = `Balance: ${this.customerBalance}`
  },

  abort: async function () {
    const { abort } = this.barter.methods;
    await this.barter.methods.abort().send({ from: this.customer });

  },

  confirmReceived: async function () {

    let result = await this.barter.methods.jobIsDone().send({ from: this.customer });
     console.log(result);
  },

  imposterConfirmReceived: async function () {

      let result = await this.barter.methods.jobIsDone().send({ from: this.imposter });
       console.log(result);
    },

  accept: async function () {
      const { confirmReceived } = this.barter.methods;
      let result = await this.barter.methods.acceptJob().send({ from: this.provider });
       console.log(result);
    },

};

window.App = App;

window.addEventListener("load", function () {
  App.web3 = new Web3(
   new Web3.providers.HttpProvider("http://127.0.0.1:7546"));

  App.start();
});
