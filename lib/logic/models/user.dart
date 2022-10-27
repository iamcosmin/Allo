class IdentifiedUser {
  const IdentifiedUser({required this.userId, required this.username});
  final String userId;
  final String username;

  List<IdentifiedUser> getIdentifiedUsersFromMap(Map<String, String> rawUsers) {
    final userList = <IdentifiedUser>[];
    rawUsers.forEach((key, value) {
      userList.add(IdentifiedUser(userId: userId, username: username));
    });
    return userList;
  }
}
