use async_graphql::{
    http::GraphiQLSource,
    EmptyMutation,
    EmptySubscription,
    Object,
    Schema,
    futures_util::future::join_all
};
use axum::{
    routing::{get, post},
    http::StatusCode,
    Json, Router,
};
use std::future::IntoFuture;

use tokio::task::JoinSet;

pub struct QueryRoot;

#[Object]
impl QueryRoot {
    async fn howdy(&self) -> &'static str {
        "partner"
    }
}

use async_graphql_axum::GraphQL;
use axum::{
    response::{self, IntoResponse}
};
// use starwars::{QueryRoot, StarWars};
use tokio::net::TcpListener;

async fn graphiql() -> impl IntoResponse {
    response::Html(GraphiQLSource::build().endpoint("/").finish())
}

#[tokio::main]
async fn main() {
    let mut set = JoinSet::new();

    let schema = Schema::build(QueryRoot, EmptyMutation, EmptySubscription)
        // .data(StarWars::new())
        .finish();

    let app = Router::new().route("/", get(graphiql).post_service(GraphQL::new(schema)));

    println!("GraphiQL IDE: http://localhost:8000");

    set.spawn(axum::serve(TcpListener::bind("0.0.0.0:8080").await.unwrap(), Router::new()).into_future());
    set.spawn(axum::serve(TcpListener::bind("0.0.0.0:8000").await.unwrap(), app).into_future());

    set.join_next().await;
    set.join_next().await;
}

async fn root() -> &'static str {
    "Hello, World!"
}
