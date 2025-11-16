# llm_backend.py (edited)
import google.generativeai as genai
import re
import traceback

API_KEY = "AIzaSyBfesS0nbMS-1iXPxdGwq3PuDLsCDpORac"   # put your API key

def generate_sql_query(user_input, system_prompt, return_raw=True):
    """
    This version enforces raw text output.
    - The system_prompt should *explicitly* instruct the model to output ONLY the desired text.
    - return_raw is kept True by default; this function will return the cleaned raw string.
    """
    try:
        genai.configure(api_key=API_KEY)
        model = genai.GenerativeModel("gemini-2.0-flash")


        # Option B: if you must combine (fallback)
        combined_prompt = system_prompt.strip() + "\n\nUSER: " + user_input.strip()

        # Generation config: deterministic + reasonable length; include stop sequences if needed.
        gen_cfg = {
            "temperature": 0.0,
            "max_output_tokens": 1500,
            # "stop_sequences": ["\n\n"]   # optional: add if you reliably want the model to stop on blank line
        }

        response = model.generate_content(
            combined_prompt,
            generation_config=gen_cfg
        )

        # Extract raw text from whichever field the SDK returned.
        raw_text = None
        if hasattr(response, "text") and response.text:
            raw_text = response.text
        elif hasattr(response, "output_text") and getattr(response, "output_text", None):
            raw_text = response.output_text
        elif hasattr(response, "candidates") and response.candidates:
            cand = response.candidates[0]
            if hasattr(cand, "content") and cand.content:
                raw_text = cand.content
            elif hasattr(cand, "text") and cand.text:
                raw_text = cand.text

        if raw_text is None:
            raw_text = str(response)

        # Minimal cleaning: strip whitespace and remove surrounding code fences (if the model still added them).
        clean = raw_text.strip()
        # remove triple-backtick fences if any (but do NOT pretty-format or parse further)
        clean = re.sub(r"^```(?:\w+)?\s*", "", clean, flags=re.IGNORECASE)
        clean = re.sub(r"\s*```$", "", clean, flags=re.IGNORECASE)
        clean = clean.strip()

        # Return the raw cleaned string (no JSON parsing, no restructuring)
        return clean

    except Exception as e:
        print("LLM Error:", repr(e))
        traceback.print_exc()
        return None
