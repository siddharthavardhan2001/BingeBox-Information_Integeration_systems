from openai import OpenAI
import re

def generate_sql_query(user_input, system_prompt,system_prompt_number):
    """
    Generate response from NVIDIA model using OpenAI-compatible API.

    Args:
        user_input (str): User message or query
        system_prompt (str): System instruction or context
        api_key (str): NVIDIA API key

    Returns:
        str: Model-generated response text or None if error
    """
    try:
        # ✅ Initialize NVIDIA-compatible OpenAI client
        client = OpenAI(
            base_url="https://integrate.api.nvidia.com/v1",
            api_key="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"
        )

        # ✅ Send both system + user prompts
        completion = client.chat.completions.create(
            model="meta/llama3-70b-instruct",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_input}
            ],
            temperature=0.5,
            top_p=1,
            max_tokens=1024,
            stream=False  # can be True if you want streaming output
        )

        # ✅ Extract full response text
        response_text = completion.choices[0].message.content

        # ✅ Optional: clean up code fences or formatting
        clean_text = re.sub(r"^```(?:\w+)?", "", response_text.strip(), flags=re.MULTILINE)
        clean_text = re.sub(r"```$", "", clean_text.strip())

        return clean_text

    except Exception as e:
        print(f"LLM Error: {e}")
        return None


# ✅ Example usage
if __name__ == "__main__":
    system_prompt = "You are a knowledgeable movie expert who answers clearly."
    user_input = "In how many movies and TV series has Keanu Reeves worked?"

    result = generate_sql_query(
        user_input=user_input,
        system_prompt=system_prompt
    )

    print(result)
