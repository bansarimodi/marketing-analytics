from __future__ import annotations

from typing import Iterable

import pandas as pd
import plotly.express as px
import streamlit as st


st.set_page_config(
    page_title="Marketing Analytics Dashboard",
    page_icon="📊",
    layout="wide",
)

st.title("Marketing Analytics Dashboard")
st.caption(
    "Executive, advertisement, lead attribution, and sales pipeline reporting."
)


@st.cache_resource
def get_connection():
    return st.connection("snowflake")


def get_object_name(model_name: str) -> str:
    database = st.secrets.get("app", {}).get(
        "database",
        "MARKETING_ANALYTICS",
    )
    schema = st.secrets.get("app", {}).get(
        "schema",
        "GOLD",
    )

    return f"{database}.{schema}.{model_name}"


@st.cache_data(ttl=600, show_spinner=False)
def load_model(model_name: str) -> pd.DataFrame:
    sql = f"select * from {get_object_name(model_name)}"

    df = get_connection().query(
        sql,
        ttl=600,
    )

    df.columns = [
        str(column).lower()
        for column in df.columns
    ]

    return df


def safe_sum(
    df: pd.DataFrame,
    column: str,
) -> float:
    if column not in df.columns or df.empty:
        return 0.0

    return float(
        pd.to_numeric(
            df[column],
            errors="coerce",
        )
        .fillna(0)
        .sum()
    )


def safe_divide(
    numerator: float,
    denominator: float,
    multiplier: float = 1.0,
) -> float:
    if denominator == 0:
        return 0.0

    return numerator / denominator * multiplier


def format_money(value: float) -> str:
    return f"${value:,.2f}"


def format_number(value: float) -> str:
    return f"{value:,.0f}"


def format_percent(value: float) -> str:
    return f"{value:,.2f}%"


def validate_columns(
    df: pd.DataFrame,
    required_columns: Iterable[str],
    model_name: str,
) -> bool:
    missing_columns = [
        column
        for column in required_columns
        if column not in df.columns
    ]

    if missing_columns:
        st.error(
            f"{model_name} is missing these columns: "
            f"{', '.join(missing_columns)}"
        )
        return False

    return True


def apply_date_filter(
    df: pd.DataFrame,
    date_column: str,
    key: str,
) -> pd.DataFrame:
    result = df.copy()

    if date_column not in result.columns:
        return result

    result[date_column] = pd.to_datetime(
        result[date_column],
        errors="coerce",
    )

    valid_dates = result[date_column].dropna()

    if valid_dates.empty:
        return result

    minimum_date = valid_dates.min().date()
    maximum_date = valid_dates.max().date()

    selected_dates = st.sidebar.date_input(
        "Date range",
        value=(minimum_date, maximum_date),
        min_value=minimum_date,
        max_value=maximum_date,
        key=key,
    )

    if (
        isinstance(selected_dates, tuple)
        and len(selected_dates) == 2
    ):
        start_date, end_date = selected_dates

        result = result[
            result[date_column]
            .dt.date
            .between(start_date, end_date)
        ]

    return result


def apply_attribution_filter(
    df: pd.DataFrame,
    key: str,
) -> pd.DataFrame:
    result = df.copy()

    if "attribution_type" not in result.columns:
        return result

    values = sorted(
        result["attribution_type"]
        .dropna()
        .astype(str)
        .unique()
        .tolist()
    )

    if not values:
        return result

    selected_value = st.sidebar.selectbox(
        "Attribution Type",
        options=values,
        key=key,
    )

    return result[
        result["attribution_type"].astype(str)
        == selected_value
    ]


def apply_multiselect_filter(
    df: pd.DataFrame,
    column: str,
    label: str,
    key: str,
) -> pd.DataFrame:
    result = df.copy()

    if column not in result.columns:
        return result

    values = sorted(
        result[column]
        .dropna()
        .astype(str)
        .unique()
        .tolist()
    )

    selected_values = st.sidebar.multiselect(
        label,
        options=values,
        key=key,
    )

    if selected_values:
        result = result[
            result[column]
            .astype(str)
            .isin(selected_values)
        ]

    return result


page = st.sidebar.radio(
    "Dashboard",
    [
        "Executive Marketing",
        "Advertisement Performance",
        "Lead Attribution",
        "Sales Pipeline",
    ],
)

st.sidebar.markdown("---")

if st.sidebar.button("Refresh Data"):
    st.cache_data.clear()
    st.rerun()


if page == "Executive Marketing":

    st.header("Executive Marketing Dashboard")

    df = load_model(
        "GOLD_EXECUTIVE_MARKETING"
    )

    required_columns = [
        "full_date",
        "attribution_type",
        "total_revenue",
        "total_marketing_cost",
        "total_profit",
        "total_attributed_leads",
        "total_attributed_sales",
        "total_impressions",
        "total_clicks",
    ]

    if validate_columns(
        df,
        required_columns,
        "GOLD_EXECUTIVE_MARKETING",
    ):

        filtered = apply_date_filter(
            df,
            "full_date",
            "executive_date",
        )

        filtered = apply_attribution_filter(
            filtered,
            "executive_attribution",
        )

        revenue = safe_sum(
            filtered,
            "total_revenue",
        )

        cost = safe_sum(
            filtered,
            "total_marketing_cost",
        )

        profit = safe_sum(
            filtered,
            "total_profit",
        )

        leads = safe_sum(
            filtered,
            "total_attributed_leads",
        )

        sales = safe_sum(
            filtered,
            "total_attributed_sales",
        )

        impressions = safe_sum(
            filtered,
            "total_impressions",
        )

        clicks = safe_sum(
            filtered,
            "total_clicks",
        )

        roi = safe_divide(
            profit,
            cost,
            100,
        )

        roas = safe_divide(
            revenue,
            cost,
        )

        ctr = safe_divide(
            clicks,
            impressions,
            100,
        )

        cvr = safe_divide(
            leads,
            clicks,
            100,
        )

        row_one = st.columns(5)

        row_one[0].metric(
            "Total Revenue",
            format_money(revenue),
        )

        row_one[1].metric(
            "Marketing Cost",
            format_money(cost),
        )

        row_one[2].metric(
            "Total Profit",
            format_money(profit),
        )

        row_one[3].metric(
            "Total Leads",
            format_number(leads),
        )

        row_one[4].metric(
            "Total Sales",
            format_number(sales),
        )

        row_two = st.columns(4)

        row_two[0].metric(
            "ROI",
            format_percent(roi),
        )

        row_two[1].metric(
            "ROAS",
            f"{roas:,.2f}",
        )

        row_two[2].metric(
            "CTR",
            format_percent(ctr),
        )

        row_two[3].metric(
            "CVR",
            format_percent(cvr),
        )

        trend = (
            filtered
            .groupby(
                "full_date",
                as_index=False,
            )
            .agg(
                revenue=(
                    "total_revenue",
                    "sum",
                ),
                marketing_cost=(
                    "total_marketing_cost",
                    "sum",
                ),
                profit=(
                    "total_profit",
                    "sum",
                ),
                leads=(
                    "total_attributed_leads",
                    "sum",
                ),
                sales=(
                    "total_attributed_sales",
                    "sum",
                ),
            )
            .sort_values("full_date")
        )

        left_column, right_column = st.columns(2)

        with left_column:

            st.subheader(
                "Revenue, Cost, and Profit Trend"
            )

            financial_trend = trend.melt(
                id_vars="full_date",
                value_vars=[
                    "revenue",
                    "marketing_cost",
                    "profit",
                ],
                var_name="metric",
                value_name="value",
            )

            financial_chart = px.line(
                financial_trend,
                x="full_date",
                y="value",
                color="metric",
                markers=True,
            )

            st.plotly_chart(
                financial_chart,
                use_container_width=True,
            )

        with right_column:

            st.subheader(
                "Lead and Sales Trend"
            )

            lead_sales_trend = trend.melt(
                id_vars="full_date",
                value_vars=[
                    "leads",
                    "sales",
                ],
                var_name="metric",
                value_name="value",
            )

            lead_sales_chart = px.line(
                lead_sales_trend,
                x="full_date",
                y="value",
                color="metric",
                markers=True,
            )

            st.plotly_chart(
                lead_sales_chart,
                use_container_width=True,
            )


elif page == "Advertisement Performance":

    st.header(
        "Advertisement Performance Dashboard"
    )

    df = load_model(
        "GOLD_AD_PERFORMANCE"
    )

    required_columns = [
        "full_date",
        "attribution_type",
        "platform_name",
        "ad_name",
        "total_impressions",
        "total_clicks",
        "total_leads",
        "total_sales",
        "total_revenue",
        "total_marketing_cost",
        "total_profit",
    ]

    if validate_columns(
        df,
        required_columns,
        "GOLD_AD_PERFORMANCE",
    ):

        filtered = apply_date_filter(
            df,
            "full_date",
            "ad_date",
        )

        filtered = apply_attribution_filter(
            filtered,
            "ad_attribution",
        )

        filtered = apply_multiselect_filter(
            filtered,
            "platform_name",
            "Platform",
            "ad_platform",
        )

        filtered = apply_multiselect_filter(
            filtered,
            "ad_name",
            "Advertisement",
            "ad_name_filter",
        )

        revenue = safe_sum(
            filtered,
            "total_revenue",
        )

        cost = safe_sum(
            filtered,
            "total_marketing_cost",
        )

        profit = safe_sum(
            filtered,
            "total_profit",
        )

        leads = safe_sum(
            filtered,
            "total_leads",
        )

        impressions = safe_sum(
            filtered,
            "total_impressions",
        )

        clicks = safe_sum(
            filtered,
            "total_clicks",
        )

        cards = st.columns(6)

        cards[0].metric(
            "Revenue",
            format_money(revenue),
        )

        cards[1].metric(
            "Marketing Cost",
            format_money(cost),
        )

        cards[2].metric(
            "Profit",
            format_money(profit),
        )

        cards[3].metric(
            "Leads",
            format_number(leads),
        )

        cards[4].metric(
            "ROI",
            format_percent(
                safe_divide(
                    profit,
                    cost,
                    100,
                )
            ),
        )

        cards[5].metric(
            "ROAS",
            f"{safe_divide(revenue, cost):,.2f}",
        )

        cards_two = st.columns(4)

        cards_two[0].metric(
            "Impressions",
            format_number(impressions),
        )

        cards_two[1].metric(
            "Clicks",
            format_number(clicks),
        )

        cards_two[2].metric(
            "CTR",
            format_percent(
                safe_divide(
                    clicks,
                    impressions,
                    100,
                )
            ),
        )

        cards_two[3].metric(
            "Cost Per Lead",
            format_money(
                safe_divide(
                    cost,
                    leads,
                )
            ),
        )

        ad_summary = (
            filtered
            .groupby(
                [
                    "ad_name",
                    "platform_name",
                ],
                as_index=False,
            )
            .agg(
                revenue=(
                    "total_revenue",
                    "sum",
                ),
                cost=(
                    "total_marketing_cost",
                    "sum",
                ),
                profit=(
                    "total_profit",
                    "sum",
                ),
                leads=(
                    "total_leads",
                    "sum",
                ),
            )
        )

        ad_summary["roi"] = ad_summary.apply(
            lambda row: safe_divide(
                row["profit"],
                row["cost"],
                100,
            ),
            axis=1,
        )

        left_column, right_column = st.columns(2)

        with left_column:

            st.subheader(
                "Top Advertisements by Revenue"
            )

            top_revenue = (
                ad_summary
                .nlargest(
                    10,
                    "revenue",
                )
                .sort_values("revenue")
            )

            revenue_chart = px.bar(
                top_revenue,
                x="revenue",
                y="ad_name",
                orientation="h",
                hover_data=[
                    "platform_name",
                ],
            )

            st.plotly_chart(
                revenue_chart,
                use_container_width=True,
            )

        with right_column:

            st.subheader(
                "Top Advertisements by Leads"
            )

            top_leads = (
                ad_summary
                .nlargest(
                    10,
                    "leads",
                )
                .sort_values("leads")
            )

            leads_chart = px.bar(
                top_leads,
                x="leads",
                y="ad_name",
                orientation="h",
                hover_data=[
                    "platform_name",
                ],
            )

            st.plotly_chart(
                leads_chart,
                use_container_width=True,
            )

        left_column, right_column = st.columns(2)

        with left_column:

            st.subheader(
                "Top Advertisements by ROI"
            )

            top_roi = (
                ad_summary[
                    ad_summary["cost"] > 0
                ]
                .nlargest(
                    10,
                    "roi",
                )
                .sort_values("roi")
            )

            roi_chart = px.bar(
                top_roi,
                x="roi",
                y="ad_name",
                orientation="h",
                hover_data=[
                    "platform_name",
                ],
            )

            st.plotly_chart(
                roi_chart,
                use_container_width=True,
            )

        with right_column:

            st.subheader(
                "Platform Performance"
            )

            platform_summary = (
                filtered
                .groupby(
                    "platform_name",
                    as_index=False,
                )
                .agg(
                    revenue=(
                        "total_revenue",
                        "sum",
                    ),
                    cost=(
                        "total_marketing_cost",
                        "sum",
                    ),
                    leads=(
                        "total_leads",
                        "sum",
                    ),
                )
            )

            platform_chart = px.bar(
                platform_summary,
                x="platform_name",
                y=[
                    "revenue",
                    "cost",
                ],
                barmode="group",
            )

            st.plotly_chart(
                platform_chart,
                use_container_width=True,
            )

        st.subheader(
            "Advertisement Details"
        )

        st.dataframe(
            ad_summary.sort_values(
                "revenue",
                ascending=False,
            ),
            use_container_width=True,
            hide_index=True,
        )


elif page == "Lead Attribution":

    st.header(
        "Lead Attribution Dashboard"
    )

    df = load_model(
        "GOLD_LEAD_ATTRIBUTION"
    )

    required_columns = [
        "full_date",
        "attribution_type",
        "platform_name",
        "campaign_name",
        "ad_name",
        "traffic_name",
        "total_leads",
    ]

    if validate_columns(
        df,
        required_columns,
        "GOLD_LEAD_ATTRIBUTION",
    ):

        filtered = apply_date_filter(
            df,
            "full_date",
            "lead_date",
        )

        filtered = apply_attribution_filter(
            filtered,
            "lead_attribution",
        )

        filtered = apply_multiselect_filter(
            filtered,
            "platform_name",
            "Platform",
            "lead_platform",
        )

        filtered = apply_multiselect_filter(
            filtered,
            "campaign_name",
            "Campaign",
            "lead_campaign",
        )

        filtered = apply_multiselect_filter(
            filtered,
            "ad_name",
            "Advertisement",
            "lead_ad",
        )

        total_leads = safe_sum(
            filtered,
            "total_leads",
        )

        st.metric(
            "Total Leads",
            format_number(total_leads),
        )

        left_column, right_column = st.columns(2)

        with left_column:

            st.subheader(
                "Leads by Platform"
            )

            platform_summary = (
                filtered
                .groupby(
                    "platform_name",
                    as_index=False,
                )["total_leads"]
                .sum()
                .sort_values(
                    "total_leads",
                    ascending=False,
                )
            )

            platform_chart = px.bar(
                platform_summary,
                x="platform_name",
                y="total_leads",
            )

            st.plotly_chart(
                platform_chart,
                use_container_width=True,
            )

        with right_column:

            st.subheader(
                "Daily Lead Trend"
            )

            lead_trend = (
                filtered
                .groupby(
                    "full_date",
                    as_index=False,
                )["total_leads"]
                .sum()
                .sort_values("full_date")
            )

            trend_chart = px.line(
                lead_trend,
                x="full_date",
                y="total_leads",
                markers=True,
            )

            st.plotly_chart(
                trend_chart,
                use_container_width=True,
            )

        left_column, right_column = st.columns(2)

        with left_column:

            st.subheader(
                "Top Campaigns by Leads"
            )

            campaign_summary = (
                filtered
                .groupby(
                    "campaign_name",
                    as_index=False,
                )["total_leads"]
                .sum()
                .nlargest(
                    10,
                    "total_leads",
                )
                .sort_values("total_leads")
            )

            campaign_chart = px.bar(
                campaign_summary,
                x="total_leads",
                y="campaign_name",
                orientation="h",
            )

            st.plotly_chart(
                campaign_chart,
                use_container_width=True,
            )

        with right_column:

            st.subheader(
                "Top Advertisements by Leads"
            )

            ad_summary = (
                filtered
                .groupby(
                    "ad_name",
                    as_index=False,
                )["total_leads"]
                .sum()
                .nlargest(
                    10,
                    "total_leads",
                )
                .sort_values("total_leads")
            )

            ad_chart = px.bar(
                ad_summary,
                x="total_leads",
                y="ad_name",
                orientation="h",
            )

            st.plotly_chart(
                ad_chart,
                use_container_width=True,
            )

        st.subheader(
            "Leads by Traffic Source"
        )

        traffic_summary = (
            filtered
            .groupby(
                "traffic_name",
                as_index=False,
            )["total_leads"]
            .sum()
            .sort_values(
                "total_leads",
                ascending=False,
            )
        )

        traffic_chart = px.bar(
            traffic_summary,
            x="traffic_name",
            y="total_leads",
        )

        st.plotly_chart(
            traffic_chart,
            use_container_width=True,
        )


elif page == "Sales Pipeline":

    st.header(
        "Sales Pipeline Dashboard"
    )

    df = load_model(
        "GOLD_SALES_PIPELINE"
    )

    required_columns = [
        "full_date",
        "total_pipeline_leads",
        "triage_calls_booked",
        "triage_calls_taken",
        "triage_no_shows",
        "strategy_calls_scheduled",
        "strategy_calls_taken",
        "total_sales",
        "contracted_revenue",
    ]

    if validate_columns(
        df,
        required_columns,
        "GOLD_SALES_PIPELINE",
    ):

        filtered = apply_date_filter(
            df,
            "full_date",
            "sales_date",
        )

        total_leads = safe_sum(
            filtered,
            "total_pipeline_leads",
        )

        triage_booked = safe_sum(
            filtered,
            "triage_calls_booked",
        )

        triage_taken = safe_sum(
            filtered,
            "triage_calls_taken",
        )

        triage_no_shows = safe_sum(
            filtered,
            "triage_no_shows",
        )

        strategy_scheduled = safe_sum(
            filtered,
            "strategy_calls_scheduled",
        )

        strategy_taken = safe_sum(
            filtered,
            "strategy_calls_taken",
        )

        total_sales = safe_sum(
            filtered,
            "total_sales",
        )

        contracted_revenue = safe_sum(
            filtered,
            "contracted_revenue",
        )

        row_one = st.columns(4)

        row_one[0].metric(
            "Pipeline Leads",
            format_number(total_leads),
        )

        row_one[1].metric(
            "Triage Booked",
            format_number(triage_booked),
        )

        row_one[2].metric(
            "Triage Taken",
            format_number(triage_taken),
        )

        row_one[3].metric(
            "Triage No-Shows",
            format_number(triage_no_shows),
        )

        row_two = st.columns(4)

        row_two[0].metric(
            "Strategy Scheduled",
            format_number(strategy_scheduled),
        )

        row_two[1].metric(
            "Strategy Taken",
            format_number(strategy_taken),
        )

        row_two[2].metric(
            "Total Sales",
            format_number(total_sales),
        )

        row_two[3].metric(
            "Contracted Revenue",
            format_money(contracted_revenue),
        )

        funnel_data = pd.DataFrame(
            {
                "stage": [
                    "Pipeline Leads",
                    "Triage Booked",
                    "Triage Taken",
                    "Strategy Scheduled",
                    "Strategy Taken",
                    "Sales",
                ],
                "value": [
                    total_leads,
                    triage_booked,
                    triage_taken,
                    strategy_scheduled,
                    strategy_taken,
                    total_sales,
                ],
            }
        )

        left_column, right_column = st.columns(2)

        with left_column:

            st.subheader(
                "Current Pipeline Summary"
            )

            funnel_chart = px.funnel(
                funnel_data,
                x="value",
                y="stage",
            )

            st.plotly_chart(
                funnel_chart,
                use_container_width=True,
            )

        with right_column:

            st.subheader(
                "Pipeline Trend"
            )

            pipeline_trend = (
                filtered
                .groupby(
                    "full_date",
                    as_index=False,
                )
                .agg(
                    leads=(
                        "total_pipeline_leads",
                        "sum",
                    ),
                    triage_taken=(
                        "triage_calls_taken",
                        "sum",
                    ),
                    strategy_scheduled=(
                        "strategy_calls_scheduled",
                        "sum",
                    ),
                    sales=(
                        "total_sales",
                        "sum",
                    ),
                )
                .sort_values("full_date")
            )

            long_trend = pipeline_trend.melt(
                id_vars="full_date",
                value_vars=[
                    "leads",
                    "triage_taken",
                    "strategy_scheduled",
                    "sales",
                ],
                var_name="stage",
                value_name="value",
            )

            pipeline_chart = px.line(
                long_trend,
                x="full_date",
                y="value",
                color="stage",
                markers=True,
            )

            st.plotly_chart(
                pipeline_chart,
                use_container_width=True,
            )

        st.subheader(
            "Attendance Rates"
        )

        attendance_rates = pd.DataFrame(
            {
                "Metric": [
                    "Triage Attendance",
                    "Strategy Attendance",
                ],
                "Rate": [
                    format_percent(
                        safe_divide(
                            triage_taken,
                            triage_booked,
                            100,
                        )
                    ),
                    format_percent(
                        safe_divide(
                            strategy_taken,
                            strategy_scheduled,
                            100,
                        )
                    ),
                ],
            }
        )

        st.dataframe(
            attendance_rates,
            use_container_width=True,
            hide_index=True,
        )