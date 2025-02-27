import { deployContract } from "./utils";

async function main() {
  const initialGreeting = "Hello, Solidity!";
  const helloWorld = await deployContract("HelloWorld", [initialGreeting]);
  console.log("HelloWorld deployed to:", helloWorld.address);

  // Verify the greeting
  const greeting = await helloWorld.read.getGreeting();
  console.log("Initial greeting:", greeting);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
