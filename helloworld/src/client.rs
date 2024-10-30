use hello_world::greeter_client::GreeterClient;
use hello_world::HelloRequest;

#[cfg(ci)]
// https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#example-setting-a-warning-message
const RESPONSE_KEY: &str = "::warning file=client.rs,line=24::RESPONSE=";
#[cfg(not(ci))]
const RESPONSE_KEY: &str = "RESPONSE=";

pub mod hello_world {
    tonic::include_proto!("helloworld");
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut client = GreeterClient::connect("http://[::1]:50051").await?;

    let request = tonic::Request::new(HelloRequest {
        name: "Tonic".into(),
    });

    let response = client.say_hello(request).await?;

    println!("{}={:?}", RESPONSE_KEY, response);

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn always_pass() {
        let _ = true;
        #[cfg(ci)]
        panic!("in GHA!!!!!");
    }
}

