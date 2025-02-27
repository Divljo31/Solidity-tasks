import { viem } from "hardhat";

export async function deployContract(contractName: string, args: any[] = []) {
  const contract = await viem.deployContract(contractName, args);
  return contract;
}
