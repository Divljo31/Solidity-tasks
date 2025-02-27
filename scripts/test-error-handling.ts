import hre from "hardhat";
import { BaseError } from "viem";

async function main() {
  console.log("Deploying ErrorHandling contract...");
  const contract = await hre.viem.deployContract("ErrorHandling", []);
  console.log("Contract deployed to:", contract.address);

  try {
    console.log("\n1. Testing require() with updateValue:");
    console.log("Trying to update with value 0 (should fail)...");
    await contract.write.updateValue([0n]);
  } catch (error: any) {
    console.log(
      "Error caught (as expected):",
      error.shortMessage || error.message
    );
  }

  try {
    console.log("\n2. Testing assert() with divide:");
    console.log("Trying to divide by zero (should fail)...");
    await contract.read.divide([10n, 0n]);
  } catch (error: any) {
    console.log(
      "Error caught (as expected):",
      error.shortMessage || error.message
    );
  }

  try {
    console.log("\n3. Testing custom error with withdraw:");
    console.log("Trying to withdraw more than balance...");
    await contract.write.withdraw([2000n]);
  } catch (error: any) {
    console.log(
      "Error caught (as expected):",
      error.shortMessage || error.message
    );
  }

  try {
    console.log("\n4. Testing complexOperation with even number:");
    await contract.write.complexOperation([42n]);
    console.log("Complex operation succeeded with input 42");
  } catch (error: any) {
    console.log("Unexpected error:", error.shortMessage || error.message);
  }

  try {
    console.log("\n5. Testing complexOperation with odd number:");
    await contract.write.complexOperation([43n]);
    console.log("This line shouldn't be reached");
  } catch (error: any) {
    console.log(
      "Error caught (as expected):",
      error.shortMessage || error.message
    );
  }

  try {
    console.log("\n6. Testing unauthorized access:");
    await contract.write.adminOperation();
    console.log("This line shouldn't be reached");
  } catch (error: any) {
    console.log(
      "Error caught (as expected):",
      error.shortMessage || error.message
    );
  }

  // Test successful operations
  console.log("\nTesting successful operations:");

  const tx1 = await contract.write.updateValue([150n]);
  console.log("Successfully updated value to 150");

  const tx2 = await contract.write.deposit([], { value: 100n });
  console.log("Successfully deposited 100 wei");

  const tx3 = await contract.write.withdraw([50n]);
  console.log("Successfully withdrew 50 wei");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Unhandled error:", error);
    process.exit(1);
  });
