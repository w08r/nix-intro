use async_graphql::{
    http::GraphiQLSource,
    EmptyMutation,
    EmptySubscription,
    Object,
    Schema
};
use axum::{
    routing::get,
    response::{self, IntoResponse},
    Router,
};
use async_graphql_axum::GraphQL;
use tokio::net::TcpListener;

pub struct QueryRoot;

#[Object]
impl QueryRoot {
    async fn howdy(&self) -> &'static str {
        "partner"
    }
}

async fn graphiql() -> impl IntoResponse {
    response::Html(GraphiQLSource::build().endpoint("/").finish())
}
#[tokio::main]
async fn main() {
    let schema = Schema::build(QueryRoot, EmptyMutation, EmptySubscription)
        .finish();

    let app = Router::new().route("/", get(graphiql).post_service(GraphQL::new(schema)));

    axum::serve(TcpListener::bind("0.0.0.0:8000").await.unwrap(), app)
        .await
        .unwrap();
}
