const { expect } = require("chai");
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { parseEther } = require("viem");

describe("PaymentHandler", function () {
  async function deployPaymentHandlerFixture() {
    const [owner, addr1, addr2] = await hre.viem.getWalletClients();
    const paymentHandler = await hre.viem.deployContract("PaymentHandler");

    return { paymentHandler, owner, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { paymentHandler, owner } = await loadFixture(
        deployPaymentHandlerFixture
      );
      expect(await paymentHandler.read.owner()).to.equal(owner.account.address);
    });

    it("Should set the correct minimum deposit", async function () {
      const { paymentHandler } = await loadFixture(deployPaymentHandlerFixture);
      expect(await paymentHandler.read.minimumDeposit()).to.equal(
        parseEther("0.01")
      );
    });
  });

  describe("Receive and Fallback", function () {
    it("Should accept ETH via receive()", async function () {
      const { paymentHandler, addr1 } = await loadFixture(
        deployPaymentHandlerFixture
      );
      const sendAmount = parseEther("0.05");

      // Send ETH directly to contract
      await addr1.sendTransaction({
        to: paymentHandler.address,
        value: sendAmount,
      });

      expect(await paymentHandler.read.getContractBalance()).to.equal(
        sendAmount
      );
      expect(
        await paymentHandler.read.getDeposits([addr1.account.address])
      ).to.equal(sendAmount);
    });

    it("Should fail when sending less than minimum deposit", async function () {
      const { paymentHandler, addr1 } = await loadFixture(
        deployPaymentHandlerFixture
      );
      const sendAmount = parseEther("0.005"); // Less than minimum

      await expect(
        addr1.sendTransaction({
          to: paymentHandler.address,
          value: sendAmount,
        })
      ).to.be.revertedWith("Amount below minimum deposit");
    });
  });

  describe("Deposit Function", function () {
    it("Should accept deposits via deposit()", async function () {
      const { paymentHandler, addr1 } = await loadFixture(
        deployPaymentHandlerFixture
      );
      const depositAmount = parseEther("0.02");

      await paymentHandler.write.deposit({
        value: depositAmount,
        account: addr1.account,
      });

      expect(
        await paymentHandler.read.getDeposits([addr1.account.address])
      ).to.equal(depositAmount);
    });
  });

  describe("Withdrawal", function () {
    it("Should allow owner to withdraw", async function () {
      const { paymentHandler, owner, addr1 } = await loadFixture(
        deployPaymentHandlerFixture
      );
      const depositAmount = parseEther("0.05");

      // First make a deposit
      await addr1.sendTransaction({
        to: paymentHandler.address,
        value: depositAmount,
      });

      // Get owner's balance before withdrawal
      const balanceBefore = await hre.viem.getBalance(owner.account.address);

      // Withdraw funds
      await paymentHandler.write.withdraw([depositAmount], {
        account: owner.account,
      });

      // Get owner's balance after withdrawal
      const balanceAfter = await hre.viem.getBalance(owner.account.address);

      // Check that owner received the funds
      expect(balanceAfter - balanceBefore).to.equal(depositAmount);
    });

    it("Should prevent non-owners from withdrawing", async function () {
      const { paymentHandler, addr1 } = await loadFixture(
        deployPaymentHandlerFixture
      );

      await expect(
        paymentHandler.write.withdraw([parseEther("0.01")], {
          account: addr1.account,
        })
      ).to.be.revertedWith("Only owner can call this function");
    });
  });
});
