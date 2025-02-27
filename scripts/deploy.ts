import hre from "hardhat";

async function main() {
  const initialGreeting = "Hello, Solidity World!";

  console.log("Deploying HelloWorld contract...");

  const helloWorld = await hre.viem.deployContract("HelloWorld", [
    initialGreeting,
  ]);

  console.log("HelloWorld deployed to:", helloWorld.address);

  // Verify the initial greeting
  const greeting = await helloWorld.read.getGreeting();
  console.log("Initial greeting:", greeting);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
