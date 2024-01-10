use async_graphql::{http::GraphiQLSource, EmptyMutation, EmptySubscription, Object, Schema, futures_util::future::join_all};
use async_graphql_poem::GraphQL;
use poem::{get, handler, listener::TcpListener, web::Html, IntoResponse, Route, Server};

#[handler]
async fn graphiql() -> impl IntoResponse {
    Html(GraphiQLSource::build().endpoint("/").finish())
}

pub struct QueryRoot;

#[Object]
impl QueryRoot {
    async fn howdy(&self) -> &'static str {
        "partner"
    }
}

#[tokio::main]
async fn main() {
    let schema = Schema::build(QueryRoot, EmptyMutation, EmptySubscription)
        .finish();

    let app = Route::new().at("/", get(graphiql).post(GraphQL::new(schema.clone())));

    println!("GraphiQL IDE: http://localhost:8000");
    Server::new(TcpListener::bind("0.0.0.0:8000"))
        .run(app)
        .await
        .unwrap()
}
