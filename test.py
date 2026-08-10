import streamlit as st

st.set_page_config(page_title="Snowflake Test")

st.title("Snowflake Connection Test")

try:
    conn = st.connection("snowflake")

    df = conn.query(
        """
        select
            current_account() as account,
            current_user() as user_name,
            current_role() as role_name,
            current_database() as database_name,
            current_schema() as schema_name
        """,
        ttl=0,
    )

    st.success("Snowflake connection successful.")
    st.dataframe(df)

except Exception as error:
    st.error("Snowflake connection failed.")
    st.exception(error)