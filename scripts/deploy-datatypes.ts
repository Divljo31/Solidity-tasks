import hre from "hardhat";

async function main() {
  const initialMessage = "Initial contract message";

  console.log("Deploying DataTypesAndVisibility contract...");

  const contract = await hre.viem.deployContract("DataTypesAndVisibility", [
    initialMessage,
  ]);

  console.log("DataTypesAndVisibility deployed to:", contract.address);

  // Test some functions
  console.log("\nTesting contract functions:");

  // Get initial message
  const message = await contract.read.getMessage();
  console.log("Initial message:", message);

  // Update and read number
  await contract.write.updateNumber([42n]);
  const [isActive, number] = await contract.read.getStatus();
  console.log("Status - isActive:", isActive, "number:", number);

  // Test pure function
  const sum = await contract.read.add([5n, 3n]);
  console.log("5 + 3 =", sum);

  // Test division
  const [quotient, remainder] = await contract.read.divide([17n, 5n]);
  console.log("17 ÷ 5 = ", quotient, "remainder", remainder);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
