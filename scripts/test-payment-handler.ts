import hre from "hardhat";
import { parseEther } from "viem";

async function main() {
  // Deploy PaymentHandler
  console.log("Deploying PaymentHandler...");
  const paymentHandler = await hre.viem.deployContract("PaymentHandler");
  console.log("PaymentHandler deployed to:", paymentHandler.address);

  // Get initial balance
  const initialBalance = await paymentHandler.read.getContractBalance();
  console.log("\nInitial contract balance:", initialBalance);

  // Test direct ETH transfer (will trigger receive function)
  console.log("\nTesting direct ETH transfer (receive function)...");
  const [signer] = await hre.viem.getWalletClients();

  const hash1 = await signer.sendTransaction({
    to: paymentHandler.address,
    value: parseEther("0.02"), // Sending 0.02 ETH
  });
  console.log("Transaction hash:", hash1);

  // Check new balance
  const balanceAfterReceive = await paymentHandler.read.getContractBalance();
  console.log("Contract balance after receive:", balanceAfterReceive);

  // Test deposit function
  console.log("\nTesting explicit deposit function...");
  const hash2 = await paymentHandler.write.deposit({
    value: parseEther("0.03"), // Sending 0.03 ETH
  });
  console.log("Transaction hash:", hash2);

  // Check final balance
  const finalBalance = await paymentHandler.read.getContractBalance();
  console.log("Final contract balance:", finalBalance);

  // Try sending below minimum (should fail)
  console.log("\nTrying to send below minimum amount...");
  try {
    await signer.sendTransaction({
      to: paymentHandler.address,
      value: parseEther("0.005"), // Sending 0.005 ETH (below minimum)
    });
    console.log("This line shouldn't be reached");
  } catch (error: any) {
    console.log(
      "Error caught (as expected):",
      error.shortMessage || error.message
    );
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Unhandled error:", error);
    process.exit(1);
  });
