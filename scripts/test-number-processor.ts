import hre from "hardhat";

async function main() {
  // Deploy MathUtils library first
  console.log("Deploying MathUtils library...");
  const mathUtils = await hre.viem.deployContract("MathUtils");
  console.log("MathUtils deployed to:", mathUtils.address);

  // Deploy NumberProcessor with library linking
  console.log("\nDeploying NumberProcessor...");
  const processor = await hre.viem.deployContract("NumberProcessor", [], {
    libraries: {
      MathUtils: mathUtils.address,
    },
  });
  console.log("NumberProcessor deployed to:", processor.address);

  // Test processNumber function (uses library and modifiers)
  console.log("\nTesting number processing...");
  const result = await processor.write.processNumber([42n]);
  console.log("Processed number 42");

  // Get the last processed number
  const lastNumber = await processor.read.lastProcessedNumber();
  console.log("Last processed number:", lastNumber);

  // Test findMaximum function (uses library directly)
  const max = await processor.read.findMaximum([100n, 200n]);
  console.log("\nMaximum of 100 and 200:", max);

  // Test modifier by toggling processing
  console.log("\nTesting modifiers...");
  await processor.write.toggleProcessing();
  console.log("Processing toggled off");

  // Try to process a number when disabled (should fail)
  try {
    await processor.write.processNumber([50n]);
    console.log("This line shouldn't be reached");
  } catch (error: any) {
    console.log(
      "Error caught (as expected):",
      error.shortMessage || error.message
    );
  }

  // Test number validation modifier
  try {
    await processor.write.processNumber([1001n]);
    console.log("This line shouldn't be reached");
  } catch (error: any) {
    console.log("\nTrying invalid number (>1000)");
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
