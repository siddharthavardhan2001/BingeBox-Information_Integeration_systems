

import psycopg


def execute_query(query):
    """
    Execute a SQL query and return results as a list of dictionaries.

    Args:
        query (str): SQL query to execute

    Returns:
        list[dict]: Query results (each row as dict).
                    Returns empty list [] if an error occurs or no rows are returned.
    """
    # Database credentials
    HOST = "localhost"
    PORT = 8002
    DATABASE = "postgres"
    USER = "postgres"
    PASSWORD = "postgres"

 


    connection = None
    cursor = None

    try:
        # Connect to database
    
        connection = psycopg.connect(
            dbname="postgres",
            user="postgres",
            password="postgres",
            host="localhost",
            port=8002,
        )


        cursor = connection.cursor()

        # Try executing the query
        cursor.execute(query)

        # Some queries (INSERT/UPDATE/DELETE) don’t return rows
        if cursor.description is None:
            connection.commit()
            return []

        # Fetch column names and rows
        column_names = [desc[0] for desc in cursor.description]
        rows = cursor.fetchall()

        return [dict(zip(column_names, row)) for row in rows]

    except psycopg.Error as e:
        # Specific database error (e.g. syntax error, invalid column)
        #print(f"Database error: {e.pgerror.strip() if e.pgerror else e}")
        print(f"Database error: {e}")
        return []

    except Exception as e:
        # Catch-all for any other errors
        print(f"Unexpected error: {e}")
        return []

    finally:
        # Ensure resources are closed properly
        if cursor:
            cursor.close()
        if connection:
            connection.close()


# Example usage
if __name__ == "__main__":
    test_queries = [
        "SELECT table_schema, table_name FROM information_schema.tables LIMIT 5;",
        "SELECT * FROM non_existent_table;",  # invalid table
        "INSERT INTO dummy_table VALUES (1);"  # non-select query
    ]

    for q in test_queries:
        print(f"\nRunning query: {q}")
        results = execute_query(q)
        print("Results:", results)
