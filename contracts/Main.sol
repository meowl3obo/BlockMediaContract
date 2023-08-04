// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract VideoContract {
    struct React {
        address[] Like;
        address[] Unlike;
    }

    struct Comment {
        uint Floor;
        address User; // 留言人
        uint CreateTimestamp; // 創建時間
        string Content; // 內容
        // React React; // 反應
    }

    struct Video {
        string Name; // 影片名稱
        string Key; // hash key
        address Author; // 作者
        string Describe;
        uint UploadTimestamp; // 上傳時間
        uint256 ViewCount; // 觀看次數
        uint256 TotalDonate; // 總贊助
        uint256 Balance; // 未領取贊助
        React React; // 反應
        Comment[] Comments; // 留言
    }

    Video videoInfo;
    uint nonce;

    constructor(
        string memory name,
        string memory key,
        address author,
        string memory describe,
        uint timestamp
    ) {
        videoInfo.Author = author;
        videoInfo.Name = name;
        videoInfo.Key = key;
        videoInfo.UploadTimestamp = timestamp;
        videoInfo.Describe = describe;
    }

    function getInfo() external view returns (Video memory) {
        return (videoInfo);
    }

    function likeVideo() public {
        address sender;
        sender = msg.sender;
        bool liked = false;
        for (uint i = 0; i < videoInfo.React.Like.length; i++) {
            if (videoInfo.React.Like[i] == sender) {
                liked = true;
            }
        }
        if (!liked) {
          for (uint i = 0; i < videoInfo.React.Unlike.length; i++) {
              if (videoInfo.React.Unlike[i] == sender) {
                  delete videoInfo.React.Unlike[i];
              }
          }
          videoInfo.React.Like.push(sender);
        }

    }

    function unlikeVideo() public {
        address sender;
        sender = msg.sender;
        bool unLiked = false;
        for (uint i = 0; i < videoInfo.React.Unlike.length; i++) {
            if (videoInfo.React.Unlike[i] == sender) {
                unLiked = true;
            }
        }
        if (!unLiked) {
          for (uint i = 0; i < videoInfo.React.Like.length; i++) {
              if (videoInfo.React.Like[i] == sender) {
                  delete videoInfo.React.Like[i];
              }
          }
          videoInfo.React.Unlike.push(sender);
        }
    }

    // function likeComment(uint floor) public {
    //     address sender;
    //     sender = msg.sender;
    //     for (uint j = 0; j < videoInfo.Comments.length; j++) {
    //         if (j == floor) {
    //             videoInfo.Comments[j].React.Like.push(sender);
    //             for (uint i = 0; i < videoInfo.Comments[j].React.Unlike.length; i++) {
    //                 if (videoInfo.Comments[j].React.Unlike[i] == sender) {
    //                     delete videoInfo.Comments[j].React.Unlike[i];
    //                 }
    //             }
    //         }
    //     }
    // }

    // function unlikeComment(uint floor) public {
    //     address sender;
    //     sender = msg.sender;
    //     for (uint j = 0; j < videoInfo.Comments.length; j++) {
    //         if (j == floor) {
    //             videoInfo.Comments[j].React.Unlike.push(sender);
    //             for (uint i = 0; i < videoInfo.Comments[j].React.Like.length; i++) {
    //                 if (videoInfo.Comments[j].React.Like[i] == sender) {
    //                     delete videoInfo.Comments[j].React.Like[i];
    //                 }
    //             }
    //         }
    //     }
    // }

    function addComment(string memory commentContent, uint timestamp) public {
        nonce++;
        // React memory commentReact;
        videoInfo.Comments.push(
            Comment(nonce, msg.sender, timestamp, commentContent)
        );
    }

    function donate() public payable {
        videoInfo.TotalDonate += msg.value;
        videoInfo.Balance += msg.value;
    }

    function getBalance() public {
        require(msg.sender != videoInfo.Author, "you are not author");
        payable(msg.sender).transfer(videoInfo.Balance);
        videoInfo.Balance = 0;
    }
}

contract VideosContract {
    struct Video {
        string Name; // 影片名稱
        string Key; // hash key
        address Author; // 作者
        address VideoContract; // 影片合約地址
        uint UploadTimestamp; // 上傳時間
        uint256 ViewCount; // 觀看次數
    }

    Video[] videos;

    uint256 number;

    function upload(
        string memory name,
        string memory key,
        string memory describe,
        uint timestamp
    ) public returns (address) {
        VideoContract newVideoContract = new VideoContract(
            name,
            key,
            msg.sender,
            describe,
            timestamp
        );
        address newVideoContractAddress = address(newVideoContract);
        videos.push(
            Video(name, key, msg.sender, newVideoContractAddress, timestamp, 0)
        );
        return newVideoContractAddress;
    }

    function getVideos() external view returns (Video[] memory) {
        return videos;
    }
}
