# 원티드 프리온보딩 챌린지 iOS 2차과정 

[Wanted Free Onboarding iOS 2nd Pre-Assignment](https://www.wanted.co.kr/events/pre_challenge_ios_2) 

## Topic - Concurrency

[https://developer.apple.com/documentation/swift/concurrency](https://developer.apple.com/documentation/swift/concurrency)

[https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)

[https://developer.apple.com/videos/play/wwdc2021/10132/](https://developer.apple.com/videos/play/wwdc2021/10132/)

한국어
[https://engineering.linecorp.com/ko/blog/about-swift-concurrency](https://engineering.linecorp.com/ko/blog/about-swift-concurrency)


### Keyword

Concurrency, GCD, Operation
Task, Async-Await, Continuation, Actors, Sendable
&nbsp;
&nbsp;


## 코드 설명

기존 Swift 방식

Controller 호출부(Call)
1. 네트워크 Response 값을 받은 Completion에서 코드를 작성하고
2. 비동기적으로 받아온 이미지를 뷰에 표시하기 위해 메인 쓰레드에서 비동기적으로 수행한다. 

Result 타입을 제외하더라도 {{}} 괄호가 두번 수행되어 코드는 들여쓰기가 되고 콜백 지옥에 갇혔다!!

```
NetworkService.shared.request(endPoint: .random) { [weak self] (result: Result<Giphy, GiphyError>) in
    guard let `self` = self else { return }
    
    switch result {
    case .success(let result):
        // ...
        
        DispatchQueue.main.async {
            guard let cell = self.tableView.cellForRow(at: index) as? ImageCell else { return }
            
            cell.configure(UIImage(data: imageData))
        }

    case .failure(let error):
        print("error: \(error.localizedDescription)")
    }
}
```
&nbsp;&nbsp;
기존 방식 네트워크 구현부 
이스케이핑 클로저(Completion Handler)를 사용하여 URL 요청이 끝난 후 결과 값을 비동기적으로 전달한다.

```
func request<T: Decodable>(endPoint: EndPoint, completion: @escaping(Result<T, GiphyError>) -> Void) {
    // Network GET/POST/PUT/DELETE 작업 수행
}
```


---------
&nbsp;
&nbsp;
&nbsp;
&nbsp;

새로운 방식 Controller 호출부
Task를 사용하여 콜백지옥에서 벗어낫다.

```
Task {
    let randomUrl = "https://api.giphy.com/v1/gifs/random?api_key=0qkSNtNaUL0XRhFBY7ov2q8VEC2FVAFy"
    let imageData = try await NetworkService.shared.downloadImage(url: randomUrl)
    
    guard let cell = self.tableView.cellForRow(at: index) as? ImageCell else { return }
    
    cell.configure(imageData)
}
```

&nbsp;
&nbsp;
함수 리턴값 앞에 async와 throws 키워드를 붙여 호출부에서 에러 처리를 하도록 하고
URL Request를 할 때는 try await 키워드를 사용하여 Async의 콜백을 기다린다.(대기한다.)
그리고 Response 값으로 실패한다면 throw를 통해 에러를 던져준다.

```
func downloadImage(url: String) async throws -> UIImage {

    /// ... 
    
    let (imageData, imageResponse) = try await URLSession.shared.data(from: imageUrl)
    
    guard let response = imageResponse as? HTTPURLResponse, response.statusCode == 200 else {
        print("jhkim Second Url Response Error!!")
        throw GiphyError.invalidResponse
    }
    
    guard let image = UIImage(data: imageData) else {
        throw GiphyError.invalidData
    }
    return image
}
```
