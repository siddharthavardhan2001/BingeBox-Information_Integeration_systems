import google.generativeai as genai
from system_prompt_two import system_prompt_2
import re

def generate_sql_query(user_input, system_prompt, system_prompt_number):
    """
    Generate SQL query from natural language input using Google Gemini.

    Args:
        user_input (str): Natural language query from user

    Returns:
        str: Generated SQL query or None if error
    """
    try:
        # Configure API key
        genai.configure(api_key="")

        if system_prompt_number == 3:
            # Initialize the model with system instruction
            model = genai.GenerativeModel(
                model_name="gemini-2.0-flash",
                system_instruction=system_prompt
            )
        else:
            # Initialize the model with system instruction
            model = genai.GenerativeModel(
                model_name="gemini-2.0-flash",
                system_instruction=system_prompt
            )




        # Generate SQL query from user input
        response = model.generate_content(user_input)

        # Extract the text content
        text = response.text

        # Remove markdown code fences (```json ... ```)
        clean_text = re.sub(r"^```(?:json)?", "", text.strip(), flags=re.IGNORECASE)
        clean_text = re.sub(r"```$", "", clean_text.strip())

        #print("response.text:", response.text)
        #print("clean text:", clean_text)

        return clean_text

    except Exception as e:
        print(f"LLM Error: {e}")
        return None
