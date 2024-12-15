# Definition for singly-linked list.
class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next

class Solution:
    def sortList(self, head: ListNode) -> ListNode:
        # Base case: if the list is empty or has only one element
        if not head or not head.next:
            return head
        
        # Step 1: Split the list into two halves
        middle = self.findMiddle(head)
        
        # Step 2: Recursively sort both halves
        left = self.sortList(head)
        right = self.sortList(middle)
        
        # Step 3: Merge the sorted halves
        return self.merge(left, right)

    # Function to find the middle of the linked list using the slow and fast pointer approach
    def findMiddle(self, head: ListNode) -> ListNode:
        slow, fast = head, head
        prev = None
        # Move fast pointer 2 steps at a time and slow pointer 1 step at a time
        while fast and fast.next:
            prev = slow
            slow = slow.next
            fast = fast.next.next
        prev.next = None
        return slow
    
    # Merge two sorted linked lists
    def merge(self, left: ListNode, right: ListNode) -> ListNode:
        dummy = ListNode(0)
        current = dummy
        
        # Merge the two lists
        while left and right:
            if left.val < right.val:
                current.next = left
                left = left.next
            else:
                current.next = right
                right = right.next
            current = current.next
        
        # Attach the remaining nodes if any
        current.next = left if left else right
        return dummy.next

# Helper function to create a linked list from a list of values
def create_linked_list(values):
    if not values:
        return None
    head = ListNode(values[0])
    current = head
    for value in values[1:]:
        current.next = ListNode(value)
        current = current.next
    return head

# Helper function to print the linked list
def print_linked_list(head):
    current = head
    while current:
        print(current.val, end=" -> " if current.next else "")
        current = current.next
    print()

# Test the solution with a sample input
values = [4, 2, 1, 3]
head = create_linked_list(values)

solution = Solution()
sorted_head = solution.sortList(head)

# Print the sorted linked list
print("Sorted Linked List:")
print_linked_list(sorted_head)
