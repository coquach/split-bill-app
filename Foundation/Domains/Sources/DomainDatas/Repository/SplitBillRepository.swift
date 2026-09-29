import Domains
import Foundation
import Supabase

public final class SplitBillRepository: ISplitBillRepository {
    private let client: SupabaseClient
    public init(client: SupabaseClient) { self.client = client }

    public func createSplitBill(_ command: CreateSplitBillCommand) async throws
        -> SplitBillCreation
    {
        do {
            let rows: [CreateSplitBillResultDTO] = try await client.rpc(
                "create_split_bill",
                params: CreateSplitBillRequest(command)
            ).execute().value

            guard let row = rows.first else {
                throw DomainError.unknown(
                    code: "SPLIT_BILL_NOT_CREATED",
                    message: "Split Bill was not returned."
                )
            }

            return row.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
    public func getSplitBills(
        role: String,
        status: String,
        page: Int,
        pageSize: Int
    ) async throws -> [SplitBill] {
        do {
            let dtos: [SplitBillDTO] = try await client.rpc(
                "get_split_bills",
                params: GetSplitBillsRequest(
                    role: role,
                    status: status,
                    page: page,
                    pageSize: pageSize
                )
            ).execute().value

            return dtos.map { $0.toDomain() }
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
    public func getSplitBill(id: UUID) async throws -> SplitBill {
        let dto: SplitBillDTO = try await client.from("split_bills").select()
            .eq("id", value: id.uuidString).single().execute().value
        return dto.toDomain()
    }
    public func getSplitBillDetail(id: UUID) async throws -> SplitBillDetail {
        do {
            let dtos: [SplitBillDetailDTO] = try await client.rpc(
                "get_split_bill_detail",
                params: ["p_split_bill_id": id]
            ).execute().value

            guard let dto = dtos.first else {
                throw DomainError.notFound
            }

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func updateSplitBill(_ command: UpdateSplitBillCommand) async throws
        -> SplitBill
    {
        let dto: SplitBillDTO = try await client.rpc(
            "update_split_bill",
            params: UpdateSplitBillRequest(command)
        ).execute().value
        return dto.toDomain()
    }
    public func closeSplitBill(id: UUID) async throws -> SplitBill {
        let dto: SplitBillDTO = try await client.rpc(
            "close_split_bill",
            params: ["p_split_bill_id": id]
        ).execute().value
        return dto.toDomain()
    }
    public func getMySplitBillRecords() async throws -> [SplitBillRecord] {
        let dtos: [SplitBillRecordDTO] = try await client.from(
            "my_split_bill_records"
        ).select().execute().value
        return dtos.map { $0.toDomain() }
    }
}
