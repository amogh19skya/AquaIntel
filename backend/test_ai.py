import asyncio
from ai_service import AquaBotAIService

async def test_domain():
    print("Testing Domain Restriction...")
    question = "Can you write a binary search tree algorithm in Python for me?"
    print(f"\nUser Prompt: '{question}'")
    
    res = await AquaBotAIService.generate_response(question)
    print("\n--- Out of Domain Response ---")
    print("Status:", res.get("status"))
    print("Reply:\n", res.get("reply"))

if __name__ == "__main__":
    asyncio.run(test_domain())
